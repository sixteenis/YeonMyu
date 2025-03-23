//
//  SplashView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/23/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    @State private var loadingFinished = false

    var body: some View {
        InitView()
            .ignoresSafeArea()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    Task {
                        let result = await UserManager.shared.checkSignInState()
                        let targetScreen: Screen = (result == .signIn) ? .tab : .login
                        appCoordinator.pushAndReset(targetScreen) // 로딩 후 루트 뷰 변경
                    }
                }
            }
    }
}


#Preview {
    SplashView()
}
