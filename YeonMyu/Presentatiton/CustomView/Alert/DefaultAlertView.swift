//
//  DefaultAlertView.swift
//  YeonMyu
//
//  Created by psm on 4/16/26.
//

import SwiftUI

// MARK: - Alert 설정 모델
struct DefaultAlertConfig {
    enum AlertIcon {
        case success  // 초록 체크
        case warning  // 주황 경고
        case logout // 로그아웃 팝업
        case delete //삭제 팝업
        
        var iconImage: Image {
            switch self {
            case .success: return Image.checkingIcon
            case .warning: return Image(systemName: "exclamationmark.triangle")
            case .logout: return Image.asLogoutIcon
            case .delete: return Image.asTrash
            }
        }
        var color: Color {
            switch self {
            case .success: return Color.checkGreenColor
            case .warning, .logout, .delete: return Color.asIconRedColor
            }
        }
    }
    
    enum ButtonStyle {
        /// 버튼 1개
        case single(title: String, action: () -> Void)
        /// 버튼 2개 (취소 + 확인)
        case double(cancelTitle: String, confirmTitle: String, cancelAction: () -> Void, confirmAction: () -> Void)
    }
    
    let icon: AlertIcon
    let title: String
    let message: String
    let buttonStyle: ButtonStyle
}

// MARK: - Alert View
struct DefaultAlertView: View {
    let config: DefaultAlertConfig
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 아이콘
                config.icon.iconImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
                    .foregroundStyle(config.icon.color)
                    .padding(.top, 24)
                    .padding(.bottom, 24)
                
                // 제목
                asText(config.title)
                    .font(.boldFont20)
                    .foregroundStyle(Color.asNewGray800)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                // 메시지
                asText(config.message)
                    .font(.font14)
                    .foregroundStyle(Color.asNewGray600)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                
                // 버튼
                buttonArea
                    .padding([.bottom, .horizontal], 12)
            }
            .background(Color.asWhite)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 24)
        }
    }
    
    @ViewBuilder
    private var buttonArea: some View {
        switch config.buttonStyle {
        case .single(let title, let action):
            Button(action: action) {
                asText(title)
                    .font(.boldFont18)
                    .foregroundStyle(Color.asWhite)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(config.icon.color)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.top, 0)
            
        case .double(let cancelTitle, let confirmTitle, let cancelAction, let confirmAction):
            HStack(spacing: 8) {
                Button(action: cancelAction) {
                    Text(cancelTitle)
                        .font(.boldFont18)
                        .foregroundStyle(Color.asNewGray700)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.asNewGray200)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Button(action: confirmAction) {
                    Text(confirmTitle)
                        .font(.boldFont18)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(config.icon.color)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
