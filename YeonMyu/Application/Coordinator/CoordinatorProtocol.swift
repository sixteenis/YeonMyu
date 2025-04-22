//
//  CoordinatorProtocol.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI

protocol CoordinatorProtocol: ObservableObject {
    var path: NavigationPath { get set }
    var sheet: Sheet? { get set }
    var fullScreenCover: FullScreenCover? { get set }
    
    func push(_ screen: Screen) // 다음 화면 이동
    func presentSheet(_ sheet: Sheet) // 시트 띄우기
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) // 풀스크린커버 띄우기
    func pop() // 이전 뷰로 이동
    func popToRoot() // 홈화면으로 이동
    func dismissSheet() // 시트 내리기
    func dismissFullScreenOver() // 풀스크린 커버 내리기
    func changeTab(tab: Tab)
}

//MARK: 필요한 뷰 추가해서 사용
//MARK: 값전달이 필요하면 필요한 파라미터 정의해서 사용. ex) postDetail 케이스
enum Screen: Identifiable, Hashable {
    var id: Self { return self } //  각 케이스가 자신을 반환하여  고유하게 식별됨
    
    // 로그인 , 홈탭
    case start
    case login  // 로그인 뷰
    case authStep1(uid: String)   // 회원가입 지역 설정
    case authStep2(uid: String, area: String)   // 회원가입 닉네임 설정
    
    case tab
    case home   //홈 뷰
    case search //검색 뷰
    case storage //보관함 뷰
    case my //마이 뷰
    
    case playDetail(id: String) //공연 상세 뷰
    case searchResult(search: String)
    
}

// 탭 뷰
enum Tab: Identifiable, Hashable {
    var id: Self { return self }
    
    case home   //홈 뷰
    case search //검색 뷰
    case storage //보관함 뷰
    case my //마이 뷰
    
}
//MARK: 필요한 뷰 추가해서 사용
enum Sheet: Identifiable, Hashable {
    var id: Self { return self }
    case auth1(uid: String)
}


//MARK: 필요한 뷰 추가해서 사용
enum FullScreenCover:  Identifiable, Hashable {
    var id: Self { return self }
    case auth1(uid: String)
    //    case dogWalkResult(walkTime: Int, walkDistance: Double, routeImage: UIImage)
}


