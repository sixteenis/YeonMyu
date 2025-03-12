//
//  UIApplication+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 3/3/25.
//

import UIKit

extension UIApplication {
    var safeAreaTop: CGFloat {
        guard let windowScene = connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return 0 }
        return window.safeAreaInsets.top
    }
}
