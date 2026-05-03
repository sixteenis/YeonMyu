//
//  ErrorHandlingViewModel.swift
//  Application Layer - ViewModel 공통 에러 처리 헬퍼
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 목적
//   모든 ViewModel 의 catch 블록에 같은 분기 로직을 복붙하지 않도록
//   공통 protocol 을 만들어 한 줄 호출로 처리.
//
//   ❌ Before
//     do { ... } catch let error as AppError {
//         switch error.scope {
//         case .global: globalErrorHandler.handle(error)
//         case .local:  localErrorMessage = error.userMessage
//         }
//     } catch is CancellationError { return }
//      catch { localErrorMessage = "..." }
//
//   ✅ After
//     do { ... } catch { handle(error) }
//
//  📌 채택 가이드
//   기존 ViewModel 들을 한 번에 다 마이그레이션하지 말고,
//   새로 만들거나 손보는 ViewModel 부터 점진 채택.
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

@MainActor
protocol ErrorHandlingViewModel: AnyObject {
    var globalErrorHandler: GlobalErrorHandler { get }
    var localErrorMessage: String? { get set }
}

extension ErrorHandlingViewModel {

    func handle(
        _ error: Error,
        file: String = #fileID,
        function: String = #function,
        line: Int = #line
    ) {
        // 1. 취소는 정상 흐름 — 무시.
        if error is CancellationError { return }

        // 2. AppError 로 정규화 (KopisAPIError, FirestoreError 등 자동 변환).
        let appError = error.asAppError()

        // 3. 로깅 (분기 전 일단 남김 — 사용자 신고 시 추적 가능).
        globalErrorHandler.logger.error(
            "viewmodel error: \(appError)",
            metadata: ["origin": "\(file):\(line)"],
            file: file, function: function, line: line
        )

        // 4. 분기 라우팅.
        switch appError.scope {
        case .global:
            globalErrorHandler.handle(appError)
        case .local:
            localErrorMessage = appError.userMessage
        }
    }
}
