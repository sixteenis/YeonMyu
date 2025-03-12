//
//  PlayCate.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

enum PrfCate: Int, CaseIterable {
    case all
    case play
    case musical
    
    var title: String {
        switch self {
        case .all:
            "전체"
        case .play:
            "연극"
        case .musical:
            "뮤지컬"
        }
    }
    var code: [String] {
        switch self {
        case .all:
            return ["AAAA", "GGGA"]
        case .play:
            return ["AAAA"]
        case .musical:
            return ["GGGA"]
        }
    }
}
