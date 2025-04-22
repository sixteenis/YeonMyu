//
//  SimplePostModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct SimplePostModel: Identifiable {
    let id = UUID()
    let postId: String //id
    let postURL: String
    let postType: String //공연 종류
    let postTitle: String
    let startDate: String
    let endDate: String
    var fullDate: String? = nil
    let location: String
    
    func getPostString() -> String {
        if self.postType == "뮤지컬" { return "뮤"}
        if self.postType == "연극" { return "연"}
        return ""
    }
    func isPlayCheck() -> Bool {
        if postType == "뮤지컬" || postType == "연극" {return true}
        return false
    }
    
}
