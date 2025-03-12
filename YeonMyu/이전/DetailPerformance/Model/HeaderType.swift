//
//  HeaderType.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/25/24.
//

import Foundation

enum HeaderType: CaseIterable {
    case first
    case second
    case third
    
    var title: String {
        switch self {
        case .first:
            "첫번째"
        case .second:
            "두번째"
        case .third:
            "세번째"
        }
    }
    var tabID: String {
        return self.title + self.title.prefix(4)
    }
}
