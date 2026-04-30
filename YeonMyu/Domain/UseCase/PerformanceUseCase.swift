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
    // 최근 작성된 리뷰 10개 가져오기
    func getRecentReviewList() async throws -> [ReviewModel] {
        return try await rankingDS.fetchRecentReviews()
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
                guard let data = try? await performanceDS.fetchBoxOffice(startDate: date, endDate: ddate, cateCode: "", area: nil) else { return }
                let latest = Array(data.map { $0.transformSimplePostModel() }.filter { $0.isPlayCheck() }.prefix(10))
                try? await rankingDS.updateRanking(items: latest)
            }
        }
        // 하루가 지나든 안지나든 firebase db에 저장된 top10 사용자에게 전달
        return cached
    }
}


extension PerformanceUseCase {
    func fetchDetailPerformance(id: String) async throws -> DetailPerformance {
        try await performanceDS.fetchDetailPerformance(id: id).transformDetailModel()
    }

    func fetchFacility(id: String) async throws -> PlaceModel {
        try await performanceDS.fetchFacility(id: id).transformPlaceModel()
    }
}

// MARK: - 홈 화면 헤더 데이터
extension PerformanceUseCase {
    // 곧 상영 예정인 공연
    func fetchNowOpenPrf() async throws -> MainHeaderPlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: 2)
        let ddate = String.getDateRelativeToToday(daysOffset: 14)
        let data = try await performanceDS.fetchPerformances(startDate: date, endDate: ddate)
        guard let post = data.randomElement() else { return nil }
        return MainHeaderPlayModel(mainTitle: "이번 주 주목할 신작", subTitle: "곧 막이 오릅니다", postURL: post.poster, postID: post.mt20id)
    }

    // 현재 날짜 기준 수상 공연
    func fetchNowYearAwardPrf() async throws -> MainHeaderPlayModel? {
        let nowDate = String.getDateRelativeToToday(daysOffset: 0)
        let beforDate = String.getDateRelativeToToday(daysOffset: -90)
        let data = try await performanceDS.fetchAward(startDate: beforDate, endDate: nowDate)
        guard let resultAward = data.randomElement() else { return nil }
        return MainHeaderPlayModel(mainTitle: "지금 가장 빛나는 공연", subTitle: "최근 수상의 영예를 안은 공연", postURL: resultAward.poster, postID: resultAward.mt20id)
    }

    // 작년 오늘 수상 공연
    func fetchLastYearAwardPrf() async throws -> MainHeaderPlayModel? {
        let lastDate = String.getLastYearDatesToyyyyMMdd()
        let data = try await performanceDS.fetchAward(startDate: lastDate, endDate: lastDate)
        guard let resultAward = data.randomElement() else { return nil }
        let postData = try await performanceDS.fetchDetailPerformance(id: resultAward.mt20id)
        return MainHeaderPlayModel(mainTitle: "작년 오늘, 수상작", subTitle: "1년전 오늘 수상 기록을 세운 랜덤 명작", postURL: postData.poster, postID: postData.mt20id)
    }

    // 지역 실시간 1위 판매 공연
    func fetchTop1HeaderPost(city: CityCode) async throws -> MainHeaderPlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: -30)
        let ddate = String.getDateRelativeToToday(daysOffset: 0)
        let data = try await performanceDS.fetchBoxOffice(startDate: date, endDate: ddate, cateCode: "AAAA", area: city.code)
        guard let post = data.randomElement() else { return nil }
        return MainHeaderPlayModel(mainTitle: "가장 많이 판매된 공연", subTitle: "\(city.rawValue) 실시간 1위", postURL: post.poster, postID: post.mt20id)
    }
}

// MARK: - 홈 화면 섹션 데이터
extension PerformanceUseCase {
    // 지역별 공연 목록
    func fetchUserAreaPlayList(area: CityCode, prfCate: PrfCate, page: Int = 1) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        for cate in prfCate.code {
            let result = try await performanceDS.fetchPerformances(startDate: String.getDateRelativeToToday(daysOffset: 0), cateCode: cate, area: area.code, page: page)
            data.append(contentsOf: result.map { $0.transformSimplePostModel() })
        }
        data.shuffle()
        return data.filter { $0.getPostString() != "" }
    }

    // 곧 상영 예정인 공연 섹션
    func fetchNowOpenPrfs() async throws -> RandomSimplePlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: 2)
        let ddate = String.getDateRelativeToToday(daysOffset: 14)
        let data = try await performanceDS.fetchPerformances(startDate: date, endDate: ddate)
        let posts = Array(data.map { $0.transformSimplePostModel() }.filter { $0.getPostString() != "" }.prefix(4))
        return RandomSimplePlayModel(mainTitle: "곧 상영 예정인 공연", subTitle: "막이 오르기 전 미리 확인해보세요.", simplePlayData: posts)
    }

    // 오픈런 공연 섹션
    func fetchOpenrunPrfs() async throws -> RandomSimplePlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: 0)
        let data = try await performanceDS.fetchPerformances(startDate: date, openrun: true)
        let posts = Array(data.map { $0.transformSimplePostModel() }.filter { $0.getPostString() != "" }.prefix(4))
        return RandomSimplePlayModel(mainTitle: "스테디셀러 오픈런 공연", subTitle: "검증된 명작", simplePlayData: posts)
    }

    // 지역 인기 순위 섹션
    func fetchTop10WithArea(city: CityCode) async throws -> RandomSimplePlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: -30)
        let ddate = String.getDateRelativeToToday(daysOffset: 0)
        let data = try await performanceDS.fetchBoxOffice(startDate: date, endDate: ddate, cateCode: "AAAA", area: city.code)
        let posts = Array(data.map { $0.transformSimplePostModel() }.prefix(4))
        return RandomSimplePlayModel(mainTitle: "\(city.rawValue) 인기 공연", subTitle: "\(city.rawValue)에서 가장 핫한 공연을 확인해보세요.", simplePlayData: posts)
    }
}
