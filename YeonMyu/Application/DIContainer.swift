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
    }

    // MARK: - UseCase 팩토리
    //
    // 기존 UseCase 들은 init 인자 없이 자체 DataSource 를 만들었음.
    // 새 init 으로 의존성 주입받게 변경 (UseCase 파일 수정 함께).

    func makePerformanceUseCase() -> PerformanceUseCase {
        PerformanceUseCase(
            userRepository: userRepository,
            performanceRepository: performanceRepository,
            appRepository: appRepository
        )
    }

    func makeUserUseCase() -> UserUseCase {
        UserUseCase(
            userRepository: userRepository,
            performanceRepository: performanceRepository,
            appRepository: appRepository
        )
    }

    // MARK: - 셋업

    /// 앱 부팅 직후 호출. Coordinator 와 UserUseCase 를 GlobalErrorHandler 와 연결.
    func wire(coordinator: MainCoordinator, userUseCase: UserUseCase) {
        globalErrorHandler.wire(coordinator: coordinator) { @MainActor in
            userUseCase.logout()
        }
    }
}
