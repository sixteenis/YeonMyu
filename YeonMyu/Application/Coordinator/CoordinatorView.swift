//
//  CoordinatorView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI
import PopupView

struct CoordinatorView: View {
    @Environment(MainCoordinator.self) var appCoordinator

    private var isToastPresented: Binding<Bool> {
        Binding(
            get: { appCoordinator.toastType != nil },
            set: { if !$0 { appCoordinator.dismissToast() } }
        )
    }

    var body: some View {
        // @Observable 객체에서 $ 양방향 바인딩을 쓰려면 @Bindable 한 번 감싸야 함.
        @Bindable var appCoordinator = appCoordinator
        return NavigationStack(path: $appCoordinator.path) {
            appCoordinator.build(appCoordinator.rootScreen)
                .navigationDestination(for: Screen.self) { screen in
                    appCoordinator.build(screen)
                }
                .sheet(item: $appCoordinator.sheet) { sheet in
                    appCoordinator.build(sheet)
                }
        }
        .hideKeyboardOnTap()
        .overlay {
            if let type = appCoordinator.alertType {
                DefaultAlertView(config: type.toConfig(dismiss: appCoordinator.dismissAlert))
                    .transition(.opacity.animation(.easeInOut(duration: 0.2)))
            }
        }
        .popup(isPresented: isToastPresented) {
            DefaultToastView()
        } customize: {
            $0
                .type(.floater(verticalPadding: 24, horizontalPadding: 16, useSafeAreaInset: true))
                .position(.bottom)
                .animation(.spring(duration: 0.3))
                .closeOnTapOutside(false)
                .isOpaque(false)
        }
    }


}
