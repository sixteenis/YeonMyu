//
//  SaveTicketModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/29/24.
//

import Foundation

struct SaveTicketModel: Hashable {
    var isReverse = false
    let imageRoute: String
    let nowState: TicketState
    
    let title: String
    let selectedActors: String
    
    let Rating: Double
    
    let review: String
    let code: String
    init(imageRoute: String, nowState: TicketState, title: String, selectedActors: String, Rating: Double, review: String, code: String) {
        self.imageRoute = imageRoute
        self.nowState = nowState
        self.title = title
        self.selectedActors = selectedActors
        self.Rating = Rating
        self.review = review
        self.code = code
    }
    init(data: TicketList) {
        self.imageRoute = "\(data.id)"
        self.nowState = TicketState.allCases.filter { $0.title == data.nowState}.first!
        self.title = data.title
        self.selectedActors = Array(data.selectActors).reduce("") { $0 + $1 + ", " }.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
        self.Rating = data.rating
        self.review = data.review
        self.code = data.date
    }
    
}
