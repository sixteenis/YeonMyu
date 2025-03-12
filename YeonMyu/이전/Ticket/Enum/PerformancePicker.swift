//
//  PerformancePicker.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/14/24.
//

import Foundation

enum PerformancePicker: CaseIterable {
    case all
    case play
    case musical
    
    var title: String {
        switch self {
        case .all: "통합"
        case .play: "예정"
        case .musical: "완료"
            
        }
    }
    
}
