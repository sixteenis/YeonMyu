//
//  DefaultToastModel.swift
//  YeonMyu
//
//  Created by 박성민 on 4/16/26.
//

import SwiftUI

// MARK: - Toast 모델
struct ToastModel: Identifiable {
    let id = UUID()
    let message: String
    let icon: Image?
    let iconTint: Color
    let duration: Double
    let actionTitle: String?
    let action: (() -> Void)?

    init(message: String, icon: Image? = nil, iconTint: Color = .checkGreenColor, duration: Double = 2.5, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        self.message = message
        self.icon = icon
        self.iconTint = iconTint
        self.duration = duration
        self.actionTitle = actionTitle
        self.action = action
    }
}
