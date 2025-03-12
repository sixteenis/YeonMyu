//
//  GenreType.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/19/24.
//

import Foundation

enum Genre: CaseIterable {
    case play
    case musical
    var title: String {
        switch self {
        case .play:
            "연극"
        case .musical:
            "뮤지컬"
        }
    }
    var codeString: String {
        switch self {
        case .play:
            return "AAAA"
        case .musical:
            return "GGGA"
        }
    }
}

