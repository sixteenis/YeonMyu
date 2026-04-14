//
//  PerformanceUseCase.swift
//  YeonMyu
//
//  Created by 박성민 on 4/8/26.
//

import Foundation

final class PerformanceUseCase {
    private let userDS = UserDataSource()
    private let performanceDS = PerformanceDataSource()
    private let rankingDS = AppDataSource()

    init() {}
    
    // 공연별 리뷰 정보 가져오기
    func getReviewData(_ postId: String) async throws -> [ReviewModel] {
        let reviews = try await performanceDS.fetchReviews(mt20id: postId)
        return reviews
    }

    // 랭킹 조회 - 하루가 지났으면 백그라운드에서 갱신 후 캐시된 값 반환
    func fetchRanking() async throws -> [SimplePostModel] {
        let (updateDate, cached) = try await rankingDS.fetchRanking()

        let isExpired: Bool
        if let updateDate {
            isExpired = Calendar.current.dateComponents([.hour], from: updateDate, to: Date()).hour ?? 0 >= 24
        } else {
            isExpired = true
        }

        // 하루가 지났다면 해당 api 요청을 통해 top10 업데이트 -> 네트워크 요청을 기다리지 않음
        if isExpired {
            Task {
                let date = String.getDateRelativeToToday(daysOffset: -30)
                let ddate = String.getDateRelativeToToday(daysOffset: 0)
                guard let data = try? await NetworkManager.shared.requestBoxOffice(startDate: date, endDate: ddate, cateCode: "", area: nil) else { return }
                let latest = Array(data.map { $0.transformSimplePostModel() }.filter { $0.isPlayCheck() }.prefix(10))
                try? await rankingDS.updateRanking(items: latest)
            }
        }
        // 하루가 지나든 안지나든 firebase db에 저장된 top10 사용자에게 전달
        return cached
    }
}
