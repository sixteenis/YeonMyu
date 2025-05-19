//
//  Date+.swift
//  YeonMyu
//
//  Created by 박성민 on 5/11/25.
//

import Foundation

extension Date {
    //  yy/MM/dd 형식으로 변환
    func asTrasnFormyy_mm_dd() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd"
        return formatter.string(from: self)
    }
    // yyyyMMdd 형식으로 반환 네트워크 전용
    func asTrasnFormyyyyMMdd() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        if formatter.string(from: self) == "00010101" { return "" }
        return formatter.string(from: self)
    }
    //날짜 선택했는지 판별 true: 날짜 선택함  false: 날짜 미선택
    func checkSelect() -> Bool {
        return self != Date.noSelect()
    }
    //날짜 선택 안할 시
    static func noSelect() -> Date {
        let calendar = Calendar.current
        let components = DateComponents(year: 1, month: 1, day: 1)
        return calendar.date(from: components)!
    }
}
