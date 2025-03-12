//
//  TicketState.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//

import Foundation

enum TicketState: CaseIterable {
    case completion
    case schedule
    
    var title: String {
        switch self {
        case .completion:
            "완료"
        case .schedule:
            "예정"
        }
    }
}
