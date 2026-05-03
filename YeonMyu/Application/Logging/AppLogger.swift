//
//  AppLogger.swift
//  Application Layer - 통합 로깅 인프라
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 기존 NetworkLogger / FirestoreLogger 와의 관계
//   - 두 로거는 그대로 둔다 (각 도메인 통신 디테일을 잘 찍고 있음)
//   - AppLogger 는 그 위에 "도메인 이벤트 / 비즈니스 로그 / 에러" 를 통합 수집
//   - 향후 Sentry/Crashlytics 같은 원격 수집기는 AppLogger 한 군데만 갈아끼우면 됨
//
//  📌 사용 예
//     AppLogger.shared.info("user logged in", metadata: ["uid": uid])
//     AppLogger.shared.error("fetch failed", metadata: ["error": "\(error)"])
//
//  📌 Console.app 검색
//     subsystem:com.YeonMyu.app 으로 필터
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation
import OSLog

// MARK: - Level

enum LogLevel: Int, Comparable {
    case debug    // 개발 디버깅용. 출시 빌드에선 보통 끔.
    case info     // 정상 흐름 ("로그인 성공", "공연 fetch 시작")
    case warning  // 회복 가능하지만 주목할 일 ("재시도 #2", "캐시 폴백")
    case error    // catch 블록에서 잡힌 진짜 에러
    case critical // 데이터 손실/보안 같이 즉시 알람 가야 하는 것

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .debug:    return "DEBUG"
        case .info:     return "INFO"
        case .warning:  return "WARN"
        case .error:    return "ERROR"
        case .critical: return "CRITICAL"
        }
    }

    var osLogType: OSLogType {
        switch self {
        case .debug:    return .debug
        case .info:     return .info
        case .warning:  return .default
        case .error:    return .error
        case .critical: return .fault
        }
    }
}

typealias LogMetadata = [String: String]

// MARK: - 프로토콜

protocol AppLogger: Sendable {
    func log(
        _ level: LogLevel,
        _ message: String,
        metadata: LogMetadata,
        file: String,
        function: String,
        line: Int
    )
}

extension AppLogger {
    func debug(_ message: String, metadata: LogMetadata = [:],
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.debug, message, metadata: metadata, file: file, function: function, line: line)
    }
    func info(_ message: String, metadata: LogMetadata = [:],
              file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.info, message, metadata: metadata, file: file, function: function, line: line)
    }
    func warning(_ message: String, metadata: LogMetadata = [:],
                 file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.warning, message, metadata: metadata, file: file, function: function, line: line)
    }
    func error(_ message: String, metadata: LogMetadata = [:],
               file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.error, message, metadata: metadata, file: file, function: function, line: line)
    }
    func critical(_ message: String, metadata: LogMetadata = [:],
                  file: String = #fileID, function: String = #function, line: Int = #line) {
        log(.critical, message, metadata: metadata, file: file, function: function, line: line)
    }
}

// MARK: - OSLog 구현

final class OSLogAppLogger: AppLogger {

    private let subsystem: String
    private let category: String

    init(subsystem: String = "com.YeonMyu.app", category: String = "App") {
        self.subsystem = subsystem
        self.category = category
    }

    func log(
        _ level: LogLevel,
        _ message: String,
        metadata: LogMetadata,
        file: String,
        function: String,
        line: Int
    ) {
        let logger = Logger(subsystem: subsystem, category: category)
        let metaString = metadata.isEmpty
            ? ""
            : " | " + metadata.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        let location = "\(file):\(line) \(function)"
        logger.log(level: level.osLogType,
                   "[\(level.label, privacy: .public)] \(message, privacy: .public)\(metaString, privacy: .public) | \(location, privacy: .public)")
    }
}

// MARK: - 전역 접근점
//
// 학습 단계에선 .shared 로 빠르게 시작.
// 운영 단계에선 DIContainer 의 logger 프로퍼티로 주입받는 게 더 좋다 (테스트 격리 가능).
extension OSLogAppLogger {
    static let shared: AppLogger = OSLogAppLogger()
}
