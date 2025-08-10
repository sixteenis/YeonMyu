//
//  String+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

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
}


