//
//  MainCoordinator.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI
import Observation

// 주의: @MainActor 를 일부러 붙이지 않습니다.
// 기존 Combine 기반 ViewModel 들의 sink 클로저(nonisolated)에서 coordinator 메서드를
// 호출하기 때문에, @MainActor 를 강제하면 모든 호출지를 Task { @MainActor } 로 감싸야 함.
// SwiftUI 메인 스레드에서만 사용한다는 전제는 기존 ObservableObject 와 동일하게 유지.
@Observable
final class MainCoordinator: CoordinatorProtocol {

    var path: NavigationPath = NavigationPath()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    var selectedTab: Tab = .home
    var rootScreen: Screen = .start // 루트 뷰를 동적으로 관리
    var alertType: AlertType? = nil
    var toastType: ToastType? = nil
    
    func push(_ screen: Screen) {
        path.append(screen)
    }
    
    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }
    
    func presentFullScreenCover(_ fullScreenCover: FullScreenCover) {
        self.fullScreenCover = fullScreenCover
    }
    
    func pop() {
        UIApplication.hideKeyboard()
        path.removeLast()
    }

    func popToRoot() {
        UIApplication.hideKeyboard()
        path.removeLast(path.count) // 빈 배열로 초기화시 RootView
    }

    func dismissSheet() {
        UIApplication.hideKeyboard()
        self.sheet = nil
    }

    func dismissFullScreenOver() {
        UIApplication.hideKeyboard()
        self.fullScreenCover = nil
    }
    
    func pushAndReset(_ screen: Screen) {
        path = NavigationPath() // 스택 초기화
        rootScreen = screen     // 루트 뷰 변경
        selectedTab = .home     // 탭 상태 초기화
    }
    
    func changeTab(tab: Tab) {
        selectedTab = tab
    }
    
    func presentAlert(_ type: AlertType) {
        alertType = type
    }
    
    func dismissAlert() {
        alertType = nil
    }

    func showToast(_ type: ToastType) {
        toastType = type
        let config = type.toConfig(dismiss: dismissToast)
        Task {
            try? await Task.sleep(for: .seconds(config.duration))
            await MainActor.run { dismissToast() }
        }
    }

    func dismissToast() {
        toastType = nil
    }
    
    // 화면
    @ViewBuilder
    func build(_ screen: Screen) -> some View {
        switch screen {
        case .start: SplashView()
        case .login: LoginView() //로그인
        case .authStep1(let uid): AuthStep1(uid: uid)
        case .authStep2(let uid, let area): AuthStep2(uid: uid, area: area)
            
        case .tab: MainTabView()
        case .home: HomeView()                                 // 홈
        case .search: SearchView() //검색 뷰
        case .storage(let selected): StorageView(selected: selected) //보관함 뷰
        case .my: MyView() //마이 뷰
        case .profileSetting: ProfileSetting() //프로필 설정 화면
        case .playDetail(let id) : PlayDetailView(postID: id)
        case .searchResult(let search, let date, let city): SearchResultView(searchText: search, date: date, city: city)
        //리뷰
        case .reviewWriteView(let postInfo): ReviewWriteView(postInfo: postInfo)
        case .reviewDetailView(let reviewInfo, let isShowMovePerfInfo): ReviewDetailView(reviewInfo: reviewInfo, isShowMovePerfInfo: isShowMovePerfInfo)
            
        }
    }
    
    // 시트
    @ViewBuilder
    func build(_ sheet: Sheet) -> some View {
        //MARK: 추가 구현시 예시 실제 사용시 삭제하고 사용하시면 됩니다.
        switch sheet {
        case .citySelect(let result, let onDismiss):
            CitySelectBottomSheetView(compltionCity: result)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(sheet.detentSize)]) //바텀시트 크기
                .onDisappear {
                    onDismiss()
                }
            
        case .dateAndPriceSelect(let selected, let date, let city):
            TotalSelectBottomSheetView(selected: selected, compltionDate: date, compltionCity: city)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(sheet.detentSize)])
                .onDisappear {
                }
        // MARK: - 가격 설정 바텀시트는 미사용 -> 추후 사용 시 별점 평가부분과 UI 분리 작업 필요!
        case .totalSelect(let selected, let date, let city, let price):
            TotalSelectBottomSheetView(selected: selected, compltionDate: date, compltionCity: city, compltionPrice: price)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(sheet.detentSize)]) 
                .onDisappear {
                }
            
        default: EmptyView()
        }
    }
    
    // 풀스크린 커버
    @ViewBuilder
    func build(_ fullScreenCover: FullScreenCover) -> some View {
        
    }
}
