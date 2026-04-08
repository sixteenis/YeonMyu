//
//  ReviewModel.swift
//  YeonMyu
//
//  Created by 박성민 on 4/6/26.
//

import Foundation
import FirebaseFirestore

struct ReviewModel {
    let reviewid: String //리뷰 고유 ID
    let mt20id: String // 공연 고유 ID
    let postType: String // 공연 종류
    let rating: Int // 평점
    let selectedPerformanceHighlights: [String]
    let selectedPerformanceFeelings: [String]
    let selectedPerformanceEnvironments: [String]
    let setting: String // 좌석
    let review: String // 후기
    let createdAt: Date // 생성일
    
    func toDictionary() -> [String: Any] {
        return [
            "reviewid": reviewid,
            "mt20id": mt20id,
            "postType": postType,
            "rating": rating,
            "selectedPerformanceHighlights": selectedPerformanceHighlights,
            "selectedPerformanceFeelings": selectedPerformanceFeelings,
            "selectedPerformanceEnvironments": selectedPerformanceEnvironments,
            "setting": setting,
            "review": review,
            "createdAt": Timestamp()
        ]
    }
}

// MARK: - 공연 관련 모델
struct LikesPerformanceModel {
    let mt20id: String // 공연 고유 ID
    let postType: String // 공연 종류
}
