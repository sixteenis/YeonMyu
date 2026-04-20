//
//  CoordinatorView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI
import PopupView

struct CoordinatorView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator

    private var isToastPresented: Binding<Bool> {
        Binding(
            get: { appCoordinator.toastType != nil },
            set: { if !$0 { appCoordinator.dismissToast() } }
        )
    }

    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
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
