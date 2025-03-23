//
//  MainCoordinator.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI

final class MainCoordinator: CoordinatorProtocol {
    
    @Published var path: NavigationPath = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
    @Published var selectedTab: Tab = .home
    @Published var rootScreen: Screen = .start // 루트 뷰를 동적으로 관리
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) {
        path.append(fullScreenCover)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count) // 빈 배열로 초기화시 RootView
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissFullScreenOver() {
        self.fullScreenCover = nil
    }
    
    func pushAndReset(_ screen: Screen) {
        path = NavigationPath() // 스택 초기화
        rootScreen = screen     // 루트 뷰 변경
    }
    
    func changeTab(tab: Tab) {
        selectedTab = tab
    }
    
    // 화면
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .start: SplashView()
        case .tab: MainTabView()
        case .login: LoginView() //로그인
            
            
        case .home: HomeView.build()                          // 홈
            
        case .authStep1(uid: let uid): AuthStep1(uid: uid)
            //        case .auth2(uid: let uid, area: let area):
        default: EmptyView()
            
        }
    }
    
    // 시트
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        //MARK: 추가 구현시 예시 실제 사용시 삭제하고 사용하시면 됩니다.
        //        switch sheet {
        //        case .dogProfile(let dogID): DogProfileView(dogID: dogID)
        //        }
    }
    
    // 풀스크린 커버
    @ViewBuilder
    func build(_ fullScreenCover: FullScreenCover) -> some View {
        
    }
}
