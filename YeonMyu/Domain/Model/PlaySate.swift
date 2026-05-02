//
//  PlaySate.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

enum PlaySate: String, CaseIterable {
    case notOpen = "공연예정"
    case open = "공연중"
    case end = "공연종료"
    
    var code: String {
        switch self {
        case .notOpen:
            return "01"
        case .open:
            return "02"
        case .end:
            return "03"
        }
    }
}
