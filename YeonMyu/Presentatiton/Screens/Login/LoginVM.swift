//
//  LoginVM.swift
//  YeonMyu
//
//  Created by 박성민 on 3/18/25.
//

import Foundation
import Combine

import CryptoKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import SwiftUICore

final class LoginVM: NSObject, ViewModeltype {
    
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output = Output()
    private var currentNonce: String?
    private var uid: String = ""
    
    
    override init() {
        self.cancellables = Set<AnyCancellable>()
        super.init()
        transform()
    }
    
    struct Input {
        let googleLoginTap = PassthroughSubject<Void,Never>()
        let kakaoLoginTap = PassthroughSubject<Void,Never>()
        let appleLoginTap = PassthroughSubject<ASAuthorizationAppleIDRequest,Never>()
        let appleLoginCompletion = PassthroughSubject<Result<ASAuthorization, any Error>,Never>()
    }
    struct Output {
        var err: String?
        var uid: String = ""
        var goJoinView = false
        var goMianView = false
    }
    func transform() {
        input.googleLoginTap
            .sink { [weak self] _ in
                guard let self else { return }
                self.googleSignIn { uid in
                    guard let uid else { return }
                    print("----구글 로그인 성공 : UID\(uid)-----")
                    self.loginStart(uid: uid)
                }
            }.store(in: &cancellables)
        
        input.kakaoLoginTap
            .sink { [weak self] _ in
                guard let self else { return }
                self.kakaoSignIn { uid in
                    guard let uid else { return }
                    print("----카카오 로그인 성공 : UID\(uid)-----")
                    self.loginStart(uid: uid)
                }
            }.store(in: &cancellables)
        
        input.appleLoginTap
            .sink { [weak self] request in
                guard let self else { return }
                let nonce = randomNonceString()
                self.currentNonce = nonce
                request.requestedScopes = [.email]
                request.nonce = sha256(nonce)
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                controller.performRequests() // ✅ 여기서 실행되어야 로그인 UI가 뜸
            }.store(in: &cancellables)
        
        input.appleLoginCompletion
            .sink { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let success):
                    if let appleIDCredential = success.credential as? ASAuthorizationAppleIDCredential {
                        appleSignIn(credential: appleIDCredential) { uid in
                            guard let uid else { return }
                            print("----애플 로그인 성공 : UID\(uid)-----")
                            self.loginStart(uid: uid)
                        }
                    }
                case .failure(_):
                    print("에러 ㅠ")
                }
                
                
                
            }.store(in: &cancellables)
        
    }
}
private extension LoginVM {
    func loginStart(uid: String) {
        Task {
            let state = await UserManager.shared.checkSignInState(uid: uid)
            await MainActor.run {
                self.output.uid = uid
                if state == .signIn { self.output.goMianView = true }
                if state == .newJoin { self.output.goJoinView = true }
            }
        }
        
    }
}
// MARK: - 구글 로그인
private extension LoginVM {
    func googleSignIn(compltion: @escaping ((String?) -> ())) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                print("구글 로그인 실패: \(error)")
                compltion(nil)
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                compltion(nil)
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            // Firebase 인증
            Auth.auth().signIn(with: credential) { authResult, error in
                if error != nil{
                    compltion(nil)
                    return
                }
                
                if let user = authResult?.user {
                    compltion(user.uid)
                    print("구글 로그인 성공 - 사용자 UID: \(user.uid)")
                }
            }
        }
    }
}
// MARK: - 카카오 로그인
private extension LoginVM {
    func kakaoSignIn(compltion: @escaping ((String?) -> ())) {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                
                self.handleKakaoLogin(oauthToken: oauthToken, error: error) { uid in
                    compltion(uid)
                }
                
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                self.handleKakaoLogin(oauthToken: oauthToken, error: error) { uid in
                    compltion(uid)
                }
            }
        }
    }
    
    func handleKakaoLogin(oauthToken: OAuthToken?, error: Error?, compltion: @escaping ((String?) -> Void)){
        if let error = error {
            print("카카오 로그인 실패: \(error)")
            compltion(nil)
        }
        
        var userUID: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        UserApi.shared.me { [weak self] (user, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("카카오 사용자 정보 획득 실패: \(error)")
                semaphore.signal()
                return
            }
            
            guard let email = user?.kakaoAccount?.email else {
                print("카카오 이메일 정보 없음")
                semaphore.signal()
                return
            }
            guard let id = user?.id else {
                print("카카오 id 없음")
                semaphore.signal()
                return
            }
            let password = String(describing: id)
            Task {
                do {
                    // Try to sign in first
                    userUID = try await self.signinWithFirebase(email: email, password: password)
                    compltion(userUID)
                } catch {
                    // If sign in fails, create new account
                    do {
                        userUID = try await self.emailAuthSignUp(email: email, password: password)
                        compltion(userUID)
                    } catch {
                        print("Firebase 인증 실패: \(error)")
                        compltion(nil)
                    }
                }
                semaphore.signal()
            }
        }
    }
    
    func signinWithFirebase(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("Firebase 로그인 실패: \(error)")
            throw error
        }
    }
    
    func emailAuthSignUp(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("Firebase 계정 생성 실패: \(error)")
            throw error
        }
    }
}
// MARK: - 애플 로그인
private extension LoginVM {
    func appleSignIn(credential: ASAuthorizationAppleIDCredential, completion: @escaping (String?) -> Void) {
        guard let appleIDToken = credential.identityToken else {
            print("Unable to fetch identity token")
            completion(nil)
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data")
            completion(nil)
            return
        }
        
        guard let nonce = currentNonce else {
            print("Nonce is nil")
            completion(nil)
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: firebaseCredential) { authResult, error in
            
            if let error = error {
                print("Firebase 인증 실패: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let user = authResult?.user else {
                print("Firebase 사용자 없음")
                completion(nil)
                return
            }
            completion(user.uid)
        }
    }
    
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            for random in randoms {
                if remainingLength == 0 { break }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.map { String(format: "%02x", $0) }.joined()
        return hashString
    }
}

// MARK: - 애플 로그인 델리게이트
extension LoginVM: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // SwiftUI일 경우 아래처럼 처리
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        input.appleLoginCompletion.send(.success(authorization))
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        input.appleLoginCompletion.send(.failure(error))
    }
}
