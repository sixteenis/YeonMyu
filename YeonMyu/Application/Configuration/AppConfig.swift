//
//  AppConfig.swift
//  Application Layer - 앱 전체 설정의 타입 안전 진입점
//
//  ─────────────────────────────────────────────────────────────────────────
//  📌 왜 Secrets 를 그대로 안 쓰고 한 단계 더 두는가?
//
//   1. **환경 분기 한 곳**: Debug 면 dev API, Release 면 prod API 같은 분기를
//      모든 호출지가 아닌 여기서만.
//
//   2. **타입 안전**: `Secrets.apiBaseURL` 은 String. 매 호출마다
//      `URL(string:)!` 하면 어딘가 nil 폭발 위험. 여기서 한 번만 변환.
//
//   3. **테스트 격리**: 테스트에선 다른 baseURL 을 주입해야 할 때 편하게 갈아끼움.
//
//   4. **검색성**: "이 앱이 어떤 외부 시스템을 쓰지?" 의 답이 한 파일에.
//
//  📌 호출 규칙
//   - 호출지에서는 `AppConfig.xxx` 만 쓴다. `Secrets.xxx` 직접 호출 금지.
//  ─────────────────────────────────────────────────────────────────────────
//

import Foundation

enum AppConfig {

    // MARK: - 환경

    enum Environment {
        case debug, staging, release

        var name: String {
            switch self {
            case .debug:   return "Debug"
            case .staging: return "Staging"
            case .release: return "Release"
            }
        }
    }

    static var environment: Environment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    // MARK: - KOPIS (공연 정보 API)

    /// KOPIS REST 베이스 URL.
    /// 환경별로 다른 엔드포인트가 필요하면 switch environment 로 분기.
    static let kopisBaseURL: String = "http://kopis.or.kr/openApi/restful/"

    static var kopisPerformanceURL: String { kopisBaseURL + "pblprfr" }   // 공연 목록/상세
    static var kopisPlaceURL: String { kopisBaseURL + "prfplc" }          // 공연시설
    static var kopisBoxOfficeURL: String { kopisBaseURL + "boxoffice" }   // 박스오피스
    static var kopisAwardURL: String { kopisBaseURL + "prfawad" }         // 수상작

    /// KOPIS 인증 키 (모든 KOPIS 요청의 service 쿼리 파라미터).
    static var kopisAPIKey: String { Secrets.kopisAPIKey }

    // MARK: - 카카오

    /// 카카오 SDK 초기화 시 사용.
    static var kakaoAppKey: String { Secrets.kakaoAppKey }

    // MARK: - OpenAI

    /// 향후 OCR 결과 분석용 OpenAI API 키.
    static var openAIAPIKey: String { Secrets.openAIAPIKey }
}
