//
//  PerformanceStateType.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//

import SwiftUI

enum PerformanceStateType {
    case open
    case close
    case notYet
    case unowned
    
    var title: String {
        switch self {
        case .open:
            "공연중"
        case .close:
            "공연종료"
        case .notYet:
            "공연예정"
        case .unowned:
            "알수없음"
        }
    }
    var backColor: Color {
        switch self {
        case .open:
            return Color(hex: "#6AC579")
        case .close:
            return Color(hex: "#FC6363")
        case .notYet:
            return Color(hex: "#709FF6")
        case .unowned:
            return Color(hex: "#6AC579")
        }
    }
}
