//
//  DIContainer.swift
//  Application Layer - Composition Root (의존성 조립소)
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 한 곳에 다 모은다
//   - 인프라 (logger, breadcrumbs, errorHandler)
//   - DataSource = Repository 단일 인스턴스
//   - UseCase 팩토리
//
//  📌 마이그레이션 가이드
//   - 새 화면/UseCase 부터는 DIContainer 를 거쳐 의존성 주입
//   - 기존 화면은 그대로 두고, 손볼 때 점진 마이그레이션
//   - 한 번에 모든 ViewModel 을 바꾸지 말 것 (자살 행위)
//
//  📌 어디서 만드나
//   YeonMyuApp 의 진입점에서 1번 생성, EnvironmentObject 처럼 주입.
//   (이번 phase 에서는 App 진입점도 함께 손봄)
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation
import Observation

@MainActor
@Observable
final class DIContainer {

    // MARK: - 인프라 (앱 전체 단일 인스턴스)

    let logger: AppLogger
    let breadcrumbs: BreadcrumbStore
    let globalErrorHandler: GlobalErrorHandler

    // MARK: - Data 레이어 (Repository = DataSource 단일 인스턴스)
    //
    // protocol 타입으로 보유 → UseCase 가 protocol 만 보고 구현체 모름.
    // Mock 으로 갈아끼우려면 init 시점에 다른 구현체를 주입.

    let performanceRepository: PerformanceRepository
    let userRepository: UserRepository
    let appRepository: AppRepository

    // MARK: - UseCase (단일 인스턴스)
    //
    // userInfo 같은 세션 상태를 보유하는 UseCase 는 앱 전체에서 같은 인스턴스를 공유해야 함.
    // → stored property 로 보관 (factory 로 매번 새로 만들면 상태 분리됨).

    let userUseCase: UserUseCase

    // MARK: - Init

    init(
        performanceRepository: PerformanceRepository = PerformanceDataSource(),
        userRepository: UserRepository = UserDataSource(),
        appRepository: AppRepository = AppDataSource()
    ) {
        let logger = OSLogAppLogger()
        let breadcrumbs = BreadcrumbStore()
        self.logger = logger
        self.breadcrumbs = breadcrumbs
        self.globalErrorHandler = GlobalErrorHandler(logger: logger, breadcrumbs: breadcrumbs)
        self.performanceRepository = performanceRepository
        self.userRepository = userRepository
        self.appRepository = appRepository
        self.userUseCase = UserUseCase(
            userRepository: userRepository,
            performanceRepository: performanceRepository,
            appRepository: appRepository
        )
    }

    // MARK: - UseCase 팩토리
    //
    // PerformanceUseCase 처럼 상태가 없는 것만 factory.
    // 상태가 있는 UseCase(UserUseCase) 는 stored property 로.

    func makePerformanceUseCase() -> PerformanceUseCase {
        PerformanceUseCase(
            userRepository: userRepository,
            performanceRepository: performanceRepository,
            appRepository: appRepository
        )
    }

    // MARK: - ViewModel 팩토리
    //
    // VM 의 모든 의존성을 한 곳에서 조립.
    // View 는 makeXxxVM(coordinator:) 만 호출 → 그래프 변경은 DIContainer 에서만 수정.

    func makeHomeVM(coordinator: MainCoordinator) -> HomeVM {
        HomeVM(
            coordinator: coordinator,
            globalErrorHandler: globalErrorHandler,
            userUseCase: userUseCase,
            perfUseCase: makePerformanceUseCase()
        )
    }

    // MARK: - 셋업

    /// 앱 부팅 직후 호출. Coordinator 를 GlobalErrorHandler 와 연결.
    /// userUseCase 는 컨테이너가 보유하므로 인자로 받지 않음.
    func wire(coordinator: MainCoordinator) {
        globalErrorHandler.wire(coordinator: coordinator) { [userUseCase] in
            userUseCase.logout()
        }
    }
}
