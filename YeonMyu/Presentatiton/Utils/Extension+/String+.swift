//
//  String+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

enum NicknameValidation {
    case valid
    case empty              // 닉네임이 비어있음
    case tooLong            // 6자 초과
    case invalidCharacter   // 특수문자·공백 포함

    var message: String {
        switch self {
        case .valid:             return ""
        case .empty:             return "닉네임을 입력해주세요."
        case .tooLong:           return "닉네임은 6자 이하로 입력해주세요."
        case .invalidCharacter:  return "한글, 영문, 숫자만 입력 가능해요."
        }
    }

    var isValid: Bool { self == .valid }
}

extension String {
    static func getLastYearDatesToyyyyMMdd() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let today = Date()
        let calendar = Calendar.current
        
        // 작년 같은 날짜 계산
        let lastYearDate = calendar.date(byAdding: .year, value: -1, to: today)!
        
        
        let lastYearString = dateFormatter.string(from: lastYearDate)
        
        return lastYearString
    }
    static func getDateRelativeToToday(daysOffset: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        let targetDate = Calendar.current.date(byAdding: .day, value: daysOffset, to: Date())!
        
        return dateFormatter.string(from: targetDate)
    }
    
    func validateNickname() -> NicknameValidation {
        if self.isEmpty { return .empty }
        if !countString(self) { return .tooLong }
        if !isValidInput(self) { return .invalidCharacter }
        return .valid
    }
    private func isValidInput(_ input: String) -> Bool {
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, options: [], range: range) != nil
    }
    
    private func countString(_ input: String) -> Bool {
        return input.count <= 6
    }
}


