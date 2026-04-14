//
//  VerticalPerformanceRepresentable.swift
//  YeonMyu
//

import Foundation

// 간단한 공연 정보를 표시하기 위한 필수 정보
protocol PerformanceDisplayable {
    var mt20id: String { get }
    var postURL: String { get }
    var postTitle: String { get }
    var startDate: String { get }
    var endDate: String { get }
    var location: String { get }
    var genreType: Genre { get }
}
