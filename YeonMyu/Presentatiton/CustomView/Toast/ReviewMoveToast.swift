//
//  ReviewMoveToast.swift
//  YeonMyu
//
//  Created by psm on 4/16/26.
//

import SwiftUI

struct ReviewMoveToast: View {
    @EnvironmentObject var appCoordinator: MainCoordinator

    var body: some View {
        if let toast = appCoordinator.toast {
            HStack(spacing: 10) {
                if let icon = toast.icon {
                    icon
                        .resizable()
                        .frame(width: 18, height: 18)
                }
                Text(toast.message)
                    .font(.font14)
                    .foregroundColor(.asWhite)

                if let actionTitle = toast.actionTitle, let action = toast.action {
                    Spacer()
                    Button(actionTitle) {
                        action()
                        appCoordinator.dismissToast()
                    }
                    .font(.font14.bold())
                    .foregroundColor(.asWhite)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color.asGray500)
            .cornerRadius(12)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onEnded { value in
                        if value.translation.height > 0 {
                            withAnimation { appCoordinator.dismissToast() }
                        }
                    }
            )
        }
    }
}
