//
//  BreadcrumbStore.swift
//  Application Layer - "에러 직전 무슨 일이?" 추적용
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 Breadcrumb 이란
//   사용자가 에러를 만나기 직전 N개의 행동을 시간순으로 기록한 것.
//   예: ui.tap save → network.request /todos → http.401 → auth.refresh.start → ...
//
//  📌 활용
//   에러 발생 시 GlobalErrorHandler 가 logger.error(metadata: [..., "breadcrumbs": ...])
//   → Sentry 같은 곳에서 보면 사용자 신고 시 즉시 원인 추적 가능.
//
//  실무에선 Sentry SDK 가 자동으로 breadcrumb 수집 기능을 갖고 있지만,
//  학습용으로 직접 구현해 메커니즘을 노출.
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation
import Observation

@MainActor
@Observable
final class BreadcrumbStore {

    struct Crumb: Identifiable {
        let id = UUID()
        let timestamp: Date
        let category: String   // "ui.tap", "network.request", "auth.refresh" 등
        let message: String
        let metadata: LogMetadata
    }

    /// 최근 N개. 너무 많이 쌓으면 메모리 낭비 + 가독성 ↓
    private(set) var crumbs: [Crumb] = []
    private let maxCount: Int

    init(maxCount: Int = 50) {
        self.maxCount = maxCount
    }

    func add(category: String, _ message: String, metadata: LogMetadata = [:]) {
        crumbs.append(Crumb(
            timestamp: Date(),
            category: category,
            message: message,
            metadata: metadata
        ))
        if crumbs.count > maxCount {
            crumbs.removeFirst(crumbs.count - maxCount)
        }
    }

    /// 에러 리포트에 첨부할 직렬화된 문자열.
    func serialized() -> String {
        let formatter = ISO8601DateFormatter()
        return crumbs.map { crumb in
            let meta = crumb.metadata.isEmpty
                ? ""
                : " " + crumb.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
            return "\(formatter.string(from: crumb.timestamp)) [\(crumb.category)] \(crumb.message)\(meta)"
        }.joined(separator: "\n")
    }
}
