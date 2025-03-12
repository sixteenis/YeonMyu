//
//  TicketMakeModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//

import Foundation

struct TicketMakeModel {
    let image: String
    var rating: Double
    let state: TicketState
    let title: String
    var actors: [ActorModel]
    var review: String
    var date: String
    var place: String
    var ticekPrice: String
    init(model: DetailPerformance, date: String) {
        self.image = model.posterURL
        self.rating = 0.0
        self.state = Self.isPastDate(date)
        self.title = model.name
        self.actors = model.actorArray.map { ActorModel(name: $0)}
        self.review = ""
        self.date = date
        self.place = model.place
        self.ticekPrice = ""
        
    }
    init() {
        self.image = ""
        self.rating = 0.0
        self.state = TicketState.completion
        self.title = ""
        self.actors = [ActorModel]()
        self.review = ""
        self.date = ""
        self.place = ""
        self.ticekPrice = ""
    }
//    init(model: SaveTicketModel) {
//        self.image = model.imageRoute
//        self.rating = model.Rating
//        self.state = model.nowState
//        self.title = model.title
//        self.actors = model.selectedActors
//        self.review = ""
//        self.date = ""
//        self.place = ""
//        self.ticekPrice = ""
//    }
    
    static func isPastDate(_ dateString: String) -> TicketState {
        // 날짜 형식 정의 (2024년 9월 7일)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
        //dateFormatter.locale = Locale(identifier: "ko_KR") // 한국어 형식

        // String -> Date 변환
        guard let inputDate = dateFormatter.date(from: dateString) else {
            print("잘못된 날짜 형식입니다.")
            return .completion
        }

        // 현재 날짜 가져오기
        let currentDate = Date()

        // 날짜 비교
        if inputDate < currentDate {
            return .completion
        } else {
            return .schedule
        }
    }
}

struct ActorModel: Hashable, Identifiable {
    let id = UUID()
    let name: String
    var isSelected: Bool = false
}
