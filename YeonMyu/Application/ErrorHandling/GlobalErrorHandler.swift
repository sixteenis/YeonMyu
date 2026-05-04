//
//  GlobalErrorHandler.swift
//  Application Layer - 전역 에러 처리기
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 책임
//   1. 어떤 ViewModel 에서든 "전역 에러" 가 발생하면 여기로 모임
//   2. 종류에 따라 적절히 분기:
//      - .unauthorized          → 세션 정리 + 로그인 화면 이동 (Coordinator 위임)
//      - .offline / .server     → AlertType.networkError 트리거 (기존 시스템 재사용)
//      - 그 외                  → AlertType.networkError fallback
//   3. 모든 전역 에러를 logger 로 기록 (관찰성)
//
//  📌 기존 AlertType 과의 관계
//   YeonMyu 는 이미 `AlertType.networkError` 가 잘 정의되어 있음.
//   GlobalErrorHandler 는 그걸 "어떤 조건에서 띄울지" 라우팅만 책임진다.
//   → 기존 UX 디자인은 그대로, 라우팅만 한 곳으로 모음.
//
//  📌 사용 예 (ViewModel 에서)
//      do {
//          let data = try await useCase.fetchSomething()
//      } catch {
//          globalErrorHandler.handle(error)
//      }
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation
import Observation

@MainActor
@Observable
final class GlobalErrorHandler {

    // MARK: - Dependencies

    @ObservationIgnored
    private weak var coordinator: MainCoordinator?

    @ObservationIgnored
    let logger: AppLogger

    @ObservationIgnored
    let breadcrumbs: BreadcrumbStore

    /// 로그아웃 콜백. UserUseCase.logout 같은 함수를 주입받는다.
    /// 직접 UserUseCase 를 의존하지 않고 클로저로 받아 결합도를 낮춤.
    @ObservationIgnored
    private var onSignOut: (@MainActor () -> Void)?

    init(
        logger: AppLogger,
        breadcrumbs: BreadcrumbStore
    ) {
        self.logger = logger
        self.breadcrumbs = breadcrumbs
    }

    /// 앱 부팅 후 Coordinator/UserUseCase 가 준비됐을 때 한 번 연결.
    func wire(coordinator: MainCoordinator, onSignOut: @escaping @MainActor () -> Void) {
        self.coordinator = coordinator
        self.onSignOut = onSignOut
    }

    // MARK: - 단일 진입점

    /// ViewModel 이 catch 에서 호출.
    /// AppError 가 아니면 자동으로 AppError 로 변환 후 라우팅.
    func handle(_ error: Error) {
        let appError = error.asAppError()

        // 모든 전역 에러는 로깅. 실무에선 여기서 Sentry 도 호출.
        logger.error("global error: \(appError)", metadata: [
            "userMessage": appError.userMessage,
            "isRetryable": "\(appError.isRetryable)",
            "breadcrumbs": breadcrumbs.serialized()
        ])

        guard appError.scope == .global else {
            // 로컬 에러는 GlobalErrorHandler 책임 아님 — 정상 흐름이면 ErrorRoutable.route(_:) 가
            // 로컬 에러를 VM.localError 로 보내므로 여기 도달하지 않는다.
            // 도달했다면 호출지가 route(_:) 거치지 않고 직접 handle() 부른 버그.
            // → 사용자에게 거짓 "네트워크 오류" 팝업을 띄우지 않고, 로깅 + (DEBUG)assert 로 개발자에게만 알림.
            logger.error("local-scope error reached GlobalErrorHandler — caller should use route(_:) or handle locally", metadata: [
                "appError": "\(appError)"
            ])
            assertionFailure("local-scope error reached GlobalErrorHandler: \(appError)")
            return
        }

        switch appError {
        case .unauthorized:
            // 세션 정리 → Coordinator 가 로그인 화면으로 이동.
            onSignOut?()
            coordinator?.pushAndReset(.login)

        case .offline, .serverUnavailable, .rateLimited:
            // 기존 AlertType.networkError 재사용 — UX 일관성 유지.
            coordinator?.presentAlert(.networkError(action: {}))

        default:
            coordinator?.presentAlert(.networkError(action: {}))
        }
    }
}
