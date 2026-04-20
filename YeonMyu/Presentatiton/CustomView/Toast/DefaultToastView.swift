//
//  DefaultToastView.swift
//  YeonMyu
//

import SwiftUI

private extension View {
    @ViewBuilder
    func toastBackground() -> some View {
        if #available(iOS 26, *) {
            self.glassEffect(in: .rect(cornerRadius: 20))
        } else {
            self
                .background(
                    ZStack {
                        Color.clear.background(.ultraThinMaterial)
                        Color.black.opacity(0.54)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
        }
    }
}

struct DefaultToastView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    
    var body: some View {
        if let config = appCoordinator.toastType?.toConfig(dismiss: appCoordinator.dismissToast) {
            HStack(spacing: 12) {
                // 아이콘 (원형 배경)
                if let icon = config.icon {
                    ZStack {
                        Circle()
                            .fill(config.iconTint)
                            .frame(width: 36, height: 36)
                        icon
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.asWhite)
                    }
                }
                
                asText(config.message)
                    .font(.font16)
                    .foregroundColor(.asNewGray200)
                
                Spacer()
                
                // 액션 버튼 (Capsule 형태) - 존재할 때만 표시
                if let actionTitle = config.actionTitle, let action = config.action {
                    
                    Button(actionTitle) {
                        action()
                    }
                    .font(.font14)
                    .foregroundColor(.asNewGray500)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)
            .toastBackground()
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
