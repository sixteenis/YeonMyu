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
    var relates: [RelatedLink]
    var guidance: String
    
    init(placeId: String, name: String, playDate: String, place: String, actors: String, actorArray: [String], teams: String, runtime: String, limitAge: String, ticketPrice: String, posterURL: String, state: PerformanceStateType, DetailPosts: [String], relates: [RelatedLink], guidance: String) {
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
        
    }
}
