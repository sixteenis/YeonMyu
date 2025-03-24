//
//  HomeState.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

protocol HomeStateProtocol {
    var contentState: ContentState { get } // 뷰 상태
    var headerPosts: [MainHeaderPlayModel] { get } //상단 랜덤 포스터
    var userInfo: UserInfoModel { get } //유저 연극 기록 정보
    var playCategorys: [PrfCate] { get } //공연 종류들
    var areaTopPrf: [SimplePostModel] { get } // 지역
    var randomPrfs: RandomSimplePlayModel { get }
    
    var selectedPost: String? { get } //공연 클릭 시
    var selectedUserInfo: UserInfo? { get }
    var userName: String { get }
    var selectedCity: CityCode { get } //선택 지역
    var selectedPrfCate: PrfCate { get } //선택된 공연 종류
    
}

protocol HomeStateActionProtocol: AnyObject {
    func getContentState(_ state: ContentState)
    func getHeaderPosts(_ posts: [MainHeaderPlayModel])
    func getRandomPrfs(_ data: RandomSimplePlayModel?)
    
    func getCity(_ city: CityCode)
    func getPlayCategoryIndex(_ index: Int) //공연 종류 선택 시
    func getSelectedUserInfo(_ info: UserInfo?)
    func getUserAreaInfoPosts(_ posts: [SimplePostModel])
    
    func getPostId(_ id: String?)
}

@Observable
final class HomeState: HomeStateProtocol, ObservableObject {
    var headerPosts: [MainHeaderPlayModel] = []
    var headerPostCnt: Int = 0
    var userInfo: UserInfoModel = UserInfoModel(likes: "", recodePlayCnt: "", schedulePlayCnt: "")
    var playCategorys = PrfCate.allCases
    
    var areaTopPrf: [SimplePostModel] = []
    
    var randomPrfs: RandomSimplePlayModel = RandomSimplePlayModel(mainTitle: "", subTitle: "", simplePlayData: [])
    
    var contentState: ContentState = .initView
    
    var selectedPost: String?
    var selectedUserInfo: UserInfo?
    var userName = UserManager.shared.getUserData().name
    var selectedCity: CityCode = UserManager.shared.getUserData().getCityCode()
    var selectedPrfCate: PrfCate = .all
}

extension HomeState: HomeStateActionProtocol {
    func getContentState(_ state: ContentState) {
        self.contentState = state
    }
    func getHeaderPosts(_ posts: [MainHeaderPlayModel]) {
        self.headerPosts = posts
    }
    func getRandomPrfs(_ data: RandomSimplePlayModel?) {
        guard let data else { return }
        self.randomPrfs = data
    }
    
    
    func getCity(_ city: CityCode) {
        self.selectedCity = city
    }
    func getPlayCategoryIndex(_ index: Int) {
        self.selectedPrfCate = PrfCate.allCases[index]
    }
    func getSelectedUserInfo(_ info: UserInfo?) {
        self.selectedUserInfo = info
    }
    func getUserAreaInfoPosts(_ posts: [SimplePostModel]) {
        self.areaTopPrf = posts
    }
    func getPostId(_ id: String?) {
        self.selectedPost = id
    }
    
}
