//
//  ReviewModel.swift
//  YeonMyu
//
//  Created by 박성민 on 4/6/26.
//

import Foundation
import FirebaseFirestore

struct ReviewModel {
    let id = UUID().uuidString
    let reviewid: String //리뷰 고유 ID
    let mt20id: String // 공연 고유 ID
    let postTitle: String // 공연 이름
    let postType: String // 공연 종류
    let rating: Int // 평점
    let selectedPerformanceHighlights: [String]
    let selectedPerformanceFeelings: [String]
    let selectedPerformanceEnvironments: [String]
    let setting: String // 좌석
    let review: String // 후기
    let createdAt: Date // 생성일
    
    let userID: String //작성자 유저 고유 ID
    let userName: String //작성자 유저 이름
    let userProfileID: Int //유저 프로필
    
    func toDictionary() -> [String: Any] {
        return [
            "reviewid": reviewid,
            "mt20id": mt20id,
            "postTitle": postTitle,
            "postType": postType,
            "rating": rating,
            "selectedPerformanceHighlights": selectedPerformanceHighlights,
            "selectedPerformanceFeelings": selectedPerformanceFeelings,
            "selectedPerformanceEnvironments": selectedPerformanceEnvironments,
            "setting": setting,
            "review": review,
            "createdAt": Timestamp(),
            "userID": userID,
            "userName": userName,
            "userProfileID": userProfileID,
            
        ]
    }
}

// MARK: - 공연 관련 모델
struct LikesPerformanceModel: Identifiable, PerformanceDisplayable {
    let id = UUID().uuidString
    let mt20id: String      // 공연 고유 ID
    let postType: String    // 공연 종류
    let postURL: String     // 포스터 이미지 URL
    let postTitle: String   // 공연 제목
    let startDate: String   // 시작일
    let endDate: String     // 종료일
    let location: String    // 공연 장소

    var genreType: Genre { Genre.transform(str: postType) }
    
    init(mt20id: String, postType: String, postURL: String, postTitle: String, startDate: String, endDate: String, location: String) {
        self.mt20id = mt20id
        self.postType = postType
        self.postURL = postURL
        self.postTitle = postTitle
        self.startDate = startDate
        self.endDate = endDate
        self.location = location
    }
    init(displayable: PerformanceDisplayable) {
        self.mt20id = displayable.mt20id
        self.postType = displayable.genreType.displayName
        self.postURL = displayable.postURL
        self.postTitle = displayable.postTitle
        self.startDate = displayable.startDate
        self.endDate = displayable.endDate
        self.location = displayable.location
    }

    func toDictionary() -> [String: Any] {
        return [
            "mt20id": mt20id,
            "postType": postType,
            "postURL": postURL,
            "postTitle": postTitle,
            "startDate": startDate,
            "endDate": endDate,
            "location": location
        ]
    }
}
