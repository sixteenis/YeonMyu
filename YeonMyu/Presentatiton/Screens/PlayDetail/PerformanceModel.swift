//
//  PerformanceModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/23/24.
//

import Foundation


struct PerformanceModel: Identifiable {
    let id = UUID()
    var emptyDetailCheck = true
    let simple: SimplePerformance
    var detail: DetailPerformance = DetailPerformance()
}

struct SimplePerformance {
    let playId: String
    let playDate: String
    let title: String
    let place: String
    let postURL: String
}
struct DetailPerformance {
    var placeId: String //장소id
    var name: String //이름
    var playDate: String //날짜
    var place: String //장소
    var actors: String //배우들
    var actorArray: [String]
    var teams: String //제작진
    var runtime: String //런타임
    var limitAge: String //연령
    var ticketPrice: String //티켓 가격
    var posterURL: String //포스터URL
    var state: PerformanceStateType //현재상태
    var DetailPosts: [String]
    var relates: [RelatedLink] //티켓 사이트
    var guidance: String //공연 시간
    var guidanceList: [String] {
        let pattern = #"\),\s*"#  // ) 뒤에 , 그리고 공백도 포함해서 제거
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(guidance.startIndex..<guidance.endIndex, in: guidance)
        let replaced = regex.stringByReplacingMatches(
                in: guidance,
                options: [],
                range: NSRange(location: 0, length: guidance.utf16.count),
                withTemplate: ")|"
            )
        return replaced.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    var ticketPriceList: [String] {
        let pattern = #"원,\s*"#  // "원" 다음에 쉼표와 공백 제거
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(ticketPrice.startIndex..<ticketPrice.endIndex, in: ticketPrice)
        let replaced = regex.stringByReplacingMatches(
            in: ticketPrice,
            options: [],
            range: range,
            withTemplate: "원|"
        )
        return replaced.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
    var genrenm: String //공연 종류
    
    init(placeId: String, name: String, playDate: String, place: String, actors: String, actorArray: [String], teams: String, runtime: String, limitAge: String, ticketPrice: String, posterURL: String, state: PerformanceStateType, DetailPosts: [String], relates: [RelatedLink], guidance: String, genrenm: String) {
        self.placeId = placeId
        self.name = name
        self.playDate = playDate
        self.place = place
        self.actors = actors
        self.actorArray = actorArray
        self.teams = teams
        self.runtime = runtime
        self.limitAge = limitAge
        self.ticketPrice = ticketPrice
        self.posterURL = posterURL
        self.state = state
        self.DetailPosts = DetailPosts
        self.relates = relates
        self.guidance = guidance
        self.genrenm = genrenm
    }
    init() {
        self.placeId = ""
        self.name = ""
        self.playDate = ""
        self.place = ""
        self.actors = ""
        self.actorArray = []
        self.teams = ""
        self.runtime = ""
        self.limitAge = ""
        self.ticketPrice = ""
        self.posterURL = ""
        self.state = .close
        self.DetailPosts = []
        self.relates = []
        self.guidance = ""
        self.genrenm = ""
    }
}
