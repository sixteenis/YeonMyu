//
//  HomeIntent.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import SwiftUI

protocol HomeIntentProtocol {
    func configureUserInfo(name: String, city: CityCode) // 유저 초기 정보 설정
    func onAppear(city: CityCode, prfCate: PrfCate) //처음 뷰 뜰 때
    func refreshAll() //새로고침 시
    func postTapped(id: String?) // 포스터 클릭 시
    func userInfoTapped(info: UserInfo?) //유저 공연 정보 기록 클릭 시
    func playCategoryTapped(_ index: Int, city: CityCode, prfCate: PrfCate) //공연 종류 선택 시
    func areaTapped(area: CityCode, prfCate: PrfCate) //지역 선택 시
    func insertHeaderData(_ data: MainHeaderPlayModel) //
}

final class HomeIntent {
    private weak var state: HomeStateActionProtocol?
    private var userCity: CityCode = .all
    private let perfUseCase = PerformanceUseCase()
    init(state: HomeStateActionProtocol?) {
        self.state = state
    }
}

extension HomeIntent: HomeIntentProtocol {
    func configureUserInfo(name: String, city: CityCode) {
        state?.setUserName(name)
        state?.getCity(city)
        userCity = city
    }
    //처음 뷰 뜰 때
    func onAppear(city: CityCode, prfCate: PrfCate) {
        Task {
            do {
                async let headerPosts       = getHeaderPostData()
                async let userAreaInfoPosts = getUserAreaPlayList(area: city, PrfCate: prfCate, page: 1)
                async let nowOpen           = nowOpenPrfs()
                async let openrun           = openrunPrfs()
                async let top10             = getTop10WithArea()
                
                state?.getHeaderPosts(try await headerPosts)
                state?.getUserAreaInfoPosts(try await userAreaInfoPosts)
                state?.getRandomPrfs(try await nowOpen)
                state?.getOpenrunPrfs(try await openrun)
                state?.getTop10Prfs(try await top10)
                
                state?.getContentState(.content)
            
            } catch {
                print("뷰가 처음 뜰때 오류 발생")
            }
        }
    }
    //새로고침 시
    func refreshAll() {
        state?.getContentState(.loading)
        Task {
            do {
                let headerPosts = try await self.getHeaderPostData()
                state?.getHeaderPosts(headerPosts)
                state?.getContentState(.content)
            
            } catch {
                print("새로 고침 중 오류 발생")
            }
        }
    }
    // 포스터 클릭 시
    func postTapped(id: String?) {
        state?.getPostId(id)
    }
    //유저 공연 정보 기록 클릭 시
    func userInfoTapped(info: UserInfo?) {
        state?.getSelectedUserInfo(info)
    }
    //공연 종류 선택 시
    func playCategoryTapped(_ index: Int, city: CityCode, prfCate: PrfCate) {
        state?.getPlayCategoryIndex(index)
        Task {
            do {
                let userAreaInfoPosts = try await getUserAreaPlayList(area: city, PrfCate: prfCate, page: 1)
                state?.getUserAreaInfoPosts(userAreaInfoPosts)
            } catch {
                print("공연 종류 선택 중 오류 발생")
            }
        }
    }
    //지역 선택 시
    func areaTapped(area: CityCode, prfCate: PrfCate) {
        state?.getCity(area)
        Task {
            do {
                let userAreaInfoPosts = try await getUserAreaPlayList(area: area, PrfCate: prfCate, page: 1)
                state?.getUserAreaInfoPosts(userAreaInfoPosts)
            } catch {
                print("공연 종류 선택 중 오류 발생")
            }
        }
        
    }
    
    func insertHeaderData(_ data: MainHeaderPlayModel) {
        state?.insertHeaderData(data)
    }
   
}

// MARK: - 랜덤 포스터 조회 부분
private extension HomeIntent {
    func getHeaderPostData() async throws -> [MainHeaderPlayModel] {
        let randomData: [() async throws -> MainHeaderPlayModel?] = [
            perfUseCase.fetchNowOpenPrf,
            perfUseCase.fetchNowYearAwardPrf,
            perfUseCase.fetchLastYearAwardPrf,
            { try await self.perfUseCase.fetchTop1HeaderPost(city: self.userCity) }
        ]

        let resultArray = await withTaskGroup(of: MainHeaderPlayModel?.self) { group in
            for request in randomData {
                group.addTask { try? await request() }
            }
            var postData: [MainHeaderPlayModel] = []
            for await data in group {
                if let data { postData.append(data) }
            }
            return postData
        }
        return resultArray.shuffled()
    }
}
// MARK: - 지역별 랜덤 공연 정보 부분
private extension HomeIntent {
    func getUserAreaPlayList(area: CityCode, PrfCate: PrfCate, page: Int?) async throws -> [SimplePostModel] {
        try await perfUseCase.fetchUserAreaPlayList(area: area, prfCate: PrfCate, page: page ?? 1)
    }

    func nowOpenPrfs() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchNowOpenPrfs()
    }

    func openrunPrfs() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchOpenrunPrfs()
    }

    func getTop10WithArea() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchTop10WithArea(city: userCity)
    }
}

