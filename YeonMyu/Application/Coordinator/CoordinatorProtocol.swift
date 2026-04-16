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

// MARK: - Alert 유형 정의
// 뷰에서는 action만 주입, 아이콘/제목/메시지는 여기서 관리
enum AlertType {
    // MARK: 단순 알림 (버튼 1개)
    case networkError(action: () -> Void)          // 네트워크 오류
    case saveReviewSuccess(action: () -> Void)           // 저장 완료
    case withdrawComplete(action: () -> Void)      // 회원탈퇴 완료
    case validation(title: String, action: () -> Void)      // 검증 오류 알림

    // MARK: 경고/확인 알림 (버튼 2개)
    case deleteReview(confirmAction: () -> Void)   // 리뷰 삭제
    case withdrawMember(confirmAction: () -> Void) // 회원탈퇴

    // MARK: 경고/확인 알림 (버튼 2개) - 추가
    case logout(confirmAction: () -> Void) // 로그아웃

    // MARK: 커스텀 알림 (DefaultAlertConfig 값을 직접 설정)
    case custom(DefaultAlertConfig)

    /// AlertType → DefaultAlertConfig 변환 (dismiss 자동 주입)
    func toConfig(dismiss: @escaping () -> Void) -> DefaultAlertConfig {
        switch self {
        case .networkError(let action):
            return DefaultAlertConfig(
                icon: .warning,
                title: "네트워크 오류",
                message: "일시적인 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.",
                buttonStyle: .single(title: "확인") { action(); dismiss() }
            )
        case .saveReviewSuccess(let action):
            return DefaultAlertConfig(
                icon: .success,
                title: "후기 작성을 완료했습니다",
                message: "작성한 후기는 마이페이지에서 확인할 수 있습니다.",
                buttonStyle: .single(title: "확인") { action(); dismiss() }
            )
        case .withdrawComplete(let action):
            return DefaultAlertConfig(
                icon: .success,
                title: "회원탈퇴가 완료되었습니다",
                message: "그동안 이용해 주셔서 감사합니다.\n고객님의 모든 데이터가 안전하게 파기되었습니다.",
                buttonStyle: .single(title: "확인") { action(); dismiss() }
            )
        case .validation(let title, let action):
            return DefaultAlertConfig(
                icon: .warning,
                title: title,
                message: "",
                buttonStyle: .single(title: "확인") { action(); dismiss() }
            )
        case .deleteReview(let confirm):
            return DefaultAlertConfig(
                icon: .delete,
                title: "후기를 삭제하시겠습니까?",
                message: "삭제된 후기는 복구할 수 없으며,\n모든 데이터가 영구히 삭제됩니다.",
                buttonStyle: .double(
                    cancelTitle: "취소", confirmTitle: "후기 삭제",
                    cancelAction: { dismiss() },
                    confirmAction: { confirm(); dismiss() }
                )
            )
        case .withdrawMember(let confirm):
            return DefaultAlertConfig(
                icon: .warning,
                title: "정말 탈퇴하시겠습니까?",
                message: "고객님의 모든 기록 및 개인정보가 삭제되며,\n삭제된 데이터는 복구할 수 없습니다.",
                buttonStyle: .double(
                    cancelTitle: "취소", confirmTitle: "회원탈퇴",
                    cancelAction: { dismiss() },
                    confirmAction: { confirm(); dismiss() }
                )
            )
        case .logout(let confirm):
            return DefaultAlertConfig(
                icon: .logout,
                title: "로그아웃 하시겠습니까?",
                message: "사용 중인 계정에서 로그아웃하며,\n로그인 화면으로 즉시 이동합니다.",
                buttonStyle: .double(
                    cancelTitle: "취소", confirmTitle: "로그아웃",
                    cancelAction: { dismiss() },
                    confirmAction: { confirm(); dismiss() }
                )
            )
        case .custom(let config):
            return config
        }
    }
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
    case storage(selected: StorageType) //보관함 뷰
    case my //마이 뷰
    
    case playDetail(mt20id: String) //공연 상세 뷰
    case searchResult(search: String, date: Date, city: CityCode)
    
    //리뷰
    case reviewWriteView(postInfo: DetailPerformance)
    case reviewDetailView(reviewInfo: ReviewModel, isShowMovePerfInfo: Bool)
    case profileSetting
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
enum Sheet: Identifiable{
    case auth1(uid: String)
    case citySelect(binding: Binding<CityCode>, onDismiss: () -> Void)
    case dateAndPriceSelect(selected: Int, date: Binding<Date>, city: Binding<CityCode>)
    case totalSelect(selected: Int, date: Binding<Date>, city: Binding<CityCode>, price: Binding<ClosedRange<Int>>)
    var id: String {
        switch self {
        case .auth1: return "auth1"
        case .citySelect: return "citySelect"
        case .dateAndPriceSelect: return "dateAndPriceSelect"
        case .totalSelect: return "totalSelect"
        }
    }
    /// 바텀시트 크기 비율
    var detentSize: CGFloat {
        switch self {
        case .citySelect: 0.45
        case .totalSelect: 0.6
        case .dateAndPriceSelect: 0.6
        default: 0.6
        }
    }
}


//MARK: 필요한 뷰 추가해서 사용
enum FullScreenCover {
    case auth1(uid: String)
    //    case dogWalkResult(walkTime: Int, walkDistance: Double, routeImage: UIImage)
}


