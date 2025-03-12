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
            return Color.green
        case .close:
            return Color.red
        case .notYet:
            return Color.orange
        case .unowned:
            return Color.red
        }
    }
}
