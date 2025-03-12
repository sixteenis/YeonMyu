//
//  TicketList.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/29/24.
//

import Foundation
import RealmSwift

final class TicketList: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var nowState: String
    @Persisted var title: String
    @Persisted var rating: Double
    @Persisted var postImage: String
    @Persisted var allActors: List<String>
    @Persisted var selectActors: List<String>
    @Persisted var ticketPrice: String
    @Persisted var review: String
    @Persisted var date: String
    @Persisted var place: String
    
    
    convenience init(nowState: String, title: String, rating: Double, postImage: String, allActors: List<String>, selectActors: List<String>, ticketPrice: String, review: String, date: String, place: String) {
        self.init()
        self.nowState = nowState
        self.title = title
        self.rating = rating
        self.postImage = postImage
        self.allActors = allActors
        self.selectActors = selectActors
        self.ticketPrice = ticketPrice
        self.review = review
        self.date = date
        self.place = place
    }
    convenience init(input model: TicketMakeModel) {
        self.init()
        self.nowState = model.state.title
        self.title = model.title
        self.rating = model.rating
        self.postImage = model.image
        self.allActors = Self.arrayToList(model.actors.map{$0.name})
        self.selectActors = Self.arrayToList(model.actors.filter{$0.isSelected}.map{$0.name})
        self.ticketPrice = model.ticekPrice
        self.review = model.review
        self.date = model.date
        self.place = model.place
    }
//    func transformSaveTicket() -> SaveTicketModel {
//        return SaveTicketModel(imageRoute: "\(self.id)", nowState: self.nowState, title: self.title, selectedActors: self.selectActors, Rating: <#T##Double#>, review: <#T##String#>, code: <#T##String#>)
//    }
    static func arrayToList(_ array: [String]) -> List<String> {
        let list = List<String>() // 빈 List 생성
        for element in array {
            list.append(element) // Array의 각 요소를 List에 추가
        }
        return list // 채워진 List 반환
    }
    
}
