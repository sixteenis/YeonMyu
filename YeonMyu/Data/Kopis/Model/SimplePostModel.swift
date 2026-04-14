//
//  SimplePostModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct SimplePostModel: Identifiable, PerformanceDisplayable {
    let id = UUID()
    let mt20id: String //id
    let genreType: Genre
    let postURL: String
    let postType: String //공연 종류
    let postTitle: String
    let startDate: String
    let endDate: String
    var fullDate: String? = nil
    let location: String
    
    init(postId: String, postURL: String, postType: String, postTitle: String, startDate: String, endDate: String, fullDate: String? = nil, location: String) {
        self.mt20id = postId
        self.genreType = Genre.transform(str: postType)
        self.postURL = postURL
        self.postType = postType
        self.postTitle = postTitle
        self.startDate = startDate
        self.endDate = endDate
        self.fullDate = fullDate
        self.location = location
        print("""
        ----- Post Info -----
        postId: \(self.mt20id)
        postURL: \(self.postURL)
        postType: \(self.postType)
        postTitle: \(self.postTitle)
        startDate: \(self.startDate)
        endDate: \(self.endDate)
        fullDate: \(self.fullDate)
        location: \(self.location)
        ---------------------
        """)
        
    }
    func getPostString() -> String {
        if self.postType == "뮤지컬" { return "뮤지컬"}
        if self.postType == "연극" { return "연극"}
        return ""
    }
    func isPlayCheck() -> Bool {
        if postType == "뮤지컬" || postType == "연극" {return true}
        return false
    }
    static func getMock() -> SimplePostModel {
        SimplePostModel(
            postId: "PF277444",
            postURL: "http://www.kopis.or.kr/upload/pfmPoster/PF_PF277444_251027_154930.gif",
            postType: "연극",
            postTitle: "이상한 나라의 이상해씨 [창원]",
            startDate: "25.10.03",
            endDate: "25.11.09",
            location: "나비아트홀"
        )
    }
}
