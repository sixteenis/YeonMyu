import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View {
    @State var signState: signState = .signOut
        
        enum signState {
            case signIn
            case signOut
        }
        
    var body: some View {
        Button {
            googleSignIn()
        } label: {
            Text("구글 로그인")
        }
        
        Button {
            fetchKakaoLogin()
        } label: {
            Text("카카오 로그인")
        }
        
        Button {
            // Action
            
        } label: {
            Text("애플 로그인")
        }
    }

    
}

private extension LoginView {
    func googleSignIn() {
        // 현재 활성화된 윈도우 씬 찾기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("❌ 루트 뷰 컨트롤러를 찾을 수 없음")
            return
        }
        
        // Google 로그인 실행
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            guard let user = result?.user, error == nil else {
                print("❌ Google 로그인 실패: \(error?.localizedDescription ?? "알 수 없는 오류")")
                return
            }
            
            print("✅ Google 로그인 성공, 사용자 이메일: \(user.profile?.email ?? "이메일 없음")")
            authenticateUser(for: user)
        }
    }
    
    func authenticateUser(for user: GIDGoogleUser) {
        guard let idToken = user.idToken?.tokenString else {
            print("❌ ID 토큰 없음")
            return
        }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("❌ Firebase 로그인 실패: \(error.localizedDescription)")
            } else {
                print("✅ Firebase 로그인 성공, 사용자 UID: \(result?.user.uid ?? "UID 없음")")
                self.signState = .signIn
            }
        }
    }
}

// MARK: - 카카오 로그인
private extension LoginView {
    func fetchKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                if let error = error {
                    print("카카오 로그인 실패: \(error)")
                } else {
                    print("카카오 로그인 성공")
                    fetchUserInfoWithKakao() // 로그인 성공 후 사용자 정보 가져오기
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                if let error = error {
                    print("카카오 로그인 실패: \(error)")
                } else {
                    print("카카오 로그인 성공")
                    fetchUserInfoWithKakao() // 로그인 성공 후 사용자 정보 가져오기
                }
            }
        }
    }
    func fetchUserInfoWithKakao() {
        UserApi.shared.me { (user, error) in
            if let error = error {
                print("사용자 정보 가져오기 실패: \(error)")
            } else {
                if let email = user?.kakaoAccount?.email {
                    print("사용자 이메일: \(email)")
                } else {
                    print("이메일 정보 없음")
                }
            }
        }
    }
}



#Preview {
    LoginView()
}
