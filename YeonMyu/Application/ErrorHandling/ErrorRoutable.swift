//
//  ErrorRoutable.swift
//  Application Layer - VM 공통 에러 라우팅 (Combine 호환)
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 목적
//   ErrorHandlingViewModel(@MainActor 강제) 와 달리, Combine sink 기반의
//   nonisolated VM 에서도 채택 가능한 가벼운 라우팅 프로토콜.
//
//  📌 분담
//   - .global (네트워크/서버/세션) → GlobalErrorHandler 가 알아서 팝업/세션처리
//   - .local  (필드 검증, notFound, decodingFailed 등) → VM 의 localError 에 세팅
//                                    → View 가 SwiftUI 표준 alert API 로 노출
//
//  📌 채택 방법
//   1. VM 이 ErrorRoutable 채택
//   2. var globalErrorHandler: GlobalErrorHandler? 노출
//   3. @Published var localError: AppError? 노출
//   4. catch 블록에서: await MainActor.run { self.route(error) }
//
//  📌 ErrorHandlingViewModel 와의 차이
//   - 이쪽: VM 자체는 nonisolated, route() 만 @MainActor → Combine sink 호환
//   - 저쪽: VM 전체가 @MainActor → async/await 기반 신규 VM 용
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

/// VM 공통 에러 라우팅. AppError.scope 기반으로 글로벌 팝업 / 로컬 property 분기.
protocol ErrorRoutable: AnyObject {
    var globalErrorHandler: GlobalErrorHandler { get }

    /// 로컬 스코프 에러 슬롯.
    /// - View 가 .alert(isPresented:error:) 같은 SwiftUI 표준 API 로 바인딩.
    /// - VM 에서 추가 가공이 필요하면 didSet/willSet 또는 별도 메서드로 자유.
    var localError: AppError? { get set }
}

extension ErrorRoutable {

    /// catch 블록에서 호출.
    /// - 취소(CancellationError) 는 정상 흐름이라 무시.
    /// - .global → GlobalErrorHandler 가 팝업/세션처리 (VM 면제).
    /// - .local  → VM 의 localError 에 세팅 → View 가 자동 표시.
    /// - 호출 컨텍스트가 nonisolated 면 `await MainActor.run { self.route(error) }` 로 감쌀 것.
    @MainActor
    func route(_ error: Error) {
        if error is CancellationError { return }
        let appError = error.asAppError()
        switch appError.scope {
        case .global:
            globalErrorHandler.handle(appError)
        case .local:
            localError = appError
        }
    }
}
