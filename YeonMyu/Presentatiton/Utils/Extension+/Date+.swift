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
}
