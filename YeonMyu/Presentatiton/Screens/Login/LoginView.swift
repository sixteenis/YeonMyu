import SwiftUI
import CryptoKit
import AuthenticationServices
import Firebase
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

struct OAuthUserData {
    var oauthId: String = ""
    var idToken: String = ""
}

struct LoginView: View {
    @State var oauthUserData = OAuthUserData()
    @State var errorMessage: String?
    @State var givenName: String?
    @State private var currentNonce: String?
    
    @State var signState: signState = .signOut
    
    enum signState {
        case signIn
        case signOut
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button(action: googleSignIn) {
                Text("구글 로그인")
            }
            
            Button(action: fetchKakaoLogin) {
                Text("카카오 로그인")
            }
            
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                            authenticateWithApple(credential: appleIDCredential)
                        }
                    case .failure(let error):
                        errorMessage = "Apple 로그인 실패: \(error.localizedDescription)"
                        print("Apple 로그인 실패: \(error.localizedDescription)")
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(height: 45)
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .task {
            do{
                let result = try await FirestoreManager.shared.createUser(uid: "123", name: "박박", area: "서울")
                print(result)
                print("---------")
            } catch {
                print("오류 발생 ㅠㅠㅠ")
                print("---------")
            }
            
        }
    }
    
}

// MARK: - 구글 로그인
private extension LoginView {
    func googleSignIn() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else { return }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { result, error in
            if let error = error {
                self.errorMessage = "구글 로그인 실패: \(error.localizedDescription)"
                print("구글 로그인 실패: \(error)")
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.errorMessage = "구글 토큰 획득 실패"
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                         accessToken: user.accessToken.tokenString)
            
            // Firebase 인증
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.errorMessage = "Firebase 인증 실패: \(error.localizedDescription)"
                    print("Firebase 인증 실패: \(error.localizedDescription)")
                    return
                }
                
                if let user = authResult?.user {
                    self.oauthUserData.oauthId = user.uid
                    self.oauthUserData.idToken = idToken
                    
                    // 사용자 이름 저장
                    if let name = result?.user.profile?.givenName {
                        self.givenName = name
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = name
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("이름 업데이트 실패: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    self.signState = .signIn
                    print("구글 로그인 성공 - 사용자 UID: \(user.uid)")
                    if let email = user.email {
                        print("사용자 이메일: \(email)")
                    }
                }
            }
        }
    }
}

// MARK: - 카카오 로그인
private extension LoginView {
    func fetchKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                self.handleKakaoLogin(oauthToken: oauthToken, error: error)
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                self.handleKakaoLogin(oauthToken: oauthToken, error: error)
            }
        }
    }
    
    func handleKakaoLogin(oauthToken: OAuthToken?, error: Error?) {
        if let error = error {
            self.errorMessage = "카카오 로그인 실패: \(error.localizedDescription)"
            print("카카오 로그인 실패: \(error)")
            return
        }
        
        guard let idToken = oauthToken?.idToken else {
            self.errorMessage = "카카오 ID 토큰 획득 실패"
            return
        }
        UserApi.shared.me { user, err in
            if let error {
                print("카카오 계정 가져오기 실패")
            }
            guard let id = user?.kakaoAccount?.email else { return }
            Task {
                let a = try await emailAuthSignUp(email: id, password: idToken)
                print(a)
            }
            
        }
        
//        let credential = OAuthProvider.credential(withProviderID: "kakao.com",
//                                                idToken: idToken,
//                                                accessToken: oauthToken?.accessToken)
        
        
        
//        // Firebase 인증
//        Auth.auth().signIn(with: credential) { authResult, error in
//            if let error = error {
//                self.errorMessage = "Firebase 인증 실패: \(error.localizedDescription)"
//                print("Firebase 인증 실패: \(error.localizedDescription)")
//                return
//            }
//            
//            if let user = authResult?.user {
//                self.oauthUserData.oauthId = user.uid
//                self.oauthUserData.idToken = idToken
//                
//                // 카카오 사용자 정보 가져오기
//                UserApi.shared.me { (kakaoUser, error) in
//                    if let error = error {
//                        print("카카오 사용자 정보 가져오기 실패: \(error)")
//                    } else if let kakaoUser = kakaoUser {
//                        if let email = kakaoUser.kakaoAccount?.email {
//                            print("사용자 이메일: \(email)")
//                        }
//                        if let name = kakaoUser.kakaoAccount?.profile?.nickname {
//                            self.givenName = name
//                            let changeRequest = user.createProfileChangeRequest()
//                            changeRequest.displayName = name
//                            changeRequest.commitChanges { error in
//                                if let error = error {
//                                    print("이름 업데이트 실패: \(error.localizedDescription)")
//                                }
//                            }
//                        }
//                    }
//                }
//                
//                self.signState = .signIn
//                print("카카오 로그인 성공 - 사용자 UID: \(user.uid)")
//            }
//        }
    }
    
    func emailAuthSignUp(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("구글 이메일 계정 생성 실패!!")
            throw error
        }
    }
    func signinWithFirebase(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            print("구글 이메일 로그인 실패!!")
            throw error
        }
    }
}

// MARK: - 애플 로그인
private extension LoginView {
    func authenticateWithApple(credential: ASAuthorizationAppleIDCredential) {
        guard let appleIDToken = credential.identityToken else {
            print("Unable to fetch identity token")
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialize token string from data")
            return
        }
        
        guard let nonce = currentNonce else {
            print("Nonce is nil")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idTokenString,
            rawNonce: nonce
        )
        
    
        Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
            if let error = error {
                self.errorMessage = "Firebase 인증 실패: \(error.localizedDescription)"
                print("Firebase 인증 실패: \(error.localizedDescription)")
                return
            }
            
            if let user = authResult?.user {
                self.oauthUserData.oauthId = user.uid
                self.oauthUserData.idToken = idTokenString
                
                if let fullName = credential.fullName,
                   let givenName = fullName.givenName {
                    self.givenName = givenName
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = givenName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            print("이름 업데이트 실패: \(error.localizedDescription)")
                        }
                    }
                }
                
                self.signState = .signIn
                print("애플 로그인 성공 - 사용자 UID: \(user.uid)")
                if let email = user.email {
                    print("사용자 이메일: \(email)")
                }
            }
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

#Preview {
    LoginView()
}
