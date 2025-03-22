import SwiftUI
import AuthenticationServices


struct LoginView: View {
    @State var errorMessage: String?
    @State var givenName: String?
    @State private var currentNonce: String?
    
    //@State var signState: signState = .signOut
    @StateObject private var vm = LoginVM()
    
    
    var body: some View {
        VStack(spacing: 20) {
            
            Button {
                vm.input.googleLoginTap.send(())
            } label: {
                Text("구글 로그인")
            }
            
            Button {
                vm.input.kakaoLoginTap.send(())
            } label: {
                Text("카카오 로그인")
            }
            
            Text("애플 로그인")
                .overlay {
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in vm.input.appleLoginTap.send(request) },
                        onCompletion: { result in vm.input.appleLoginCompletion.send(result)}
                    )
                    .blendMode(.overlay)
                }
            
        }
        
    }
}


#Preview {
    LoginView()
}
