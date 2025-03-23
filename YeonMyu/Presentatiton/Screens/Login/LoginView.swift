//
//  LoginView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/18/25.
//

import SwiftUI
import AuthenticationServices


struct LoginView: View {
    @StateObject private var vm = LoginVM()
    @EnvironmentObject var appCoordinator: MainCoordinator
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                LoginTitleView()
                    .vCenter()
                    .padding(.bottom, 50)
                Spacer()
                
                LoginButtons()
                    .padding(.bottom, 50)
                
            }
        }
        .onChange(of: vm.output.goJoinView) { oldValue, newValue in
            appCoordinator.push(.authStep1(uid: vm.output.uid))
        }
        .onChange(of: vm.output.goMianView) { oldValue, newValue in
            appCoordinator.pushAndReset(.tab)
        }
    }
}
private extension LoginView {
    func LoginTitleView() -> some View {
        VStack {
            Image.logoL
                .resizable()
                .frame(width: 166.67, height: 34)
                .foregroundStyle(Color.asPurple300)
                .padding(.bottom, 23)
            
            Image.loginText
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 205)
                .foregroundStyle(Color.asGray100)
        }
    }
    func LoginButtons() -> some View {
        VStack(spacing: 6) {
            Button {
                vm.input.googleLoginTap.send(())
            } label: {
                Image.googleLogin
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 22)
            }
            
            Button {
                vm.input.kakaoLoginTap.send(())
            } label: {
                Image.kakaoLogin
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 22)
            }
            Button {
                let request = ASAuthorizationAppleIDProvider().createRequest()
                vm.input.appleLoginTap.send(request)
            } label: {
                Image.appleLogin
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 22)
            }
        }
    }
    
}


#Preview {
    LoginView()
}
