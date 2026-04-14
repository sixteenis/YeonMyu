//
//  VerticalPerformanceRepresentable.swift
//  YeonMyu
//

import Foundation

protocol VerticalPerformanceRepresentable {
    var postURL: String { get }
    var postTitle: String { get }
    var startDate: String { get }
    var endDate: String { get }
    var fullDate: String? { get }
    var location: String { get }
    func getPostString() -> String
}
