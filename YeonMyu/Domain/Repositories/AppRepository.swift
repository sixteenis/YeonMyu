//
//  AppRepository.swift
//  Domain Layer - 앱 단위 공통 데이터 저장소 추상
//
//  랭킹, 최근 리뷰 같이 "특정 사용자/공연이 아닌 앱 전역 데이터" 를 다룸.
//

import Foundation

protocol AppRepository: AnyObject {
    // 랭킹
    func fetchRanking() async throws -> (updateDate: Date?, ranking: [SimplePostModel])
    func updateRanking(items: [SimplePostModel]) async throws

    // 최근 리뷰
    func saveRecentReview(_ review: ReviewModel) async throws
    func removeRecentReviewIfExists(reviewid: String) async throws
    func fetchRecentReviews() async throws -> [ReviewModel]
}

extension AppDataSource: AppRepository {}
