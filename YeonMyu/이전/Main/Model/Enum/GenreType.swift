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
    var displayName: String {
        switch self {
        case .play:
            "연극"
        case .musical:
            "뮤지컬"
        }
    }
    var tagText: String {
        switch self {
        case .play:
            "연"
        case .musical:
            "뮤"
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
    static func transform(str: String) -> Genre {
        if str == "연극" {
            return .play
        }
        return .musical
    }
}

