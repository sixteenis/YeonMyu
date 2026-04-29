# 🎭 내 안의 연뮤
> "실시간 공연을 살펴보고, 관람한 공연을 후기와 함께 기록해 보세요!"

<br>

## 📱 주요 기능

<div align="center">
    <table>
        <tr>
            <th>홈</th>
            <th>공연상세</th>
            <th>공연검색</th>
            <th>마이페이지</th>
        </tr>
        <tr>
            <td><img src="https://github.com/user-attachments/assets/65dd37f9-065e-4259-8f7c-892ee3fc066f" width="150" /></td>
            <td><img src="https://github.com/user-attachments/assets/3e848373-7e7c-4819-a0ae-8412acef60bb" width="150" /></td>
            <td><img src="https://github.com/user-attachments/assets/ee64b5fc-699d-4e4f-9646-3b1f0c8e8808" width="150" /></td>
            <td><img src="https://github.com/user-attachments/assets/fe552893-39a2-4fd3-80be-8f6f863a5944" width="150" /></td>
        </tr>
    </table>
</div>

> 🔥 지역별·장르별 실시간 공연 조회  
> 🔍 제목 · 날짜 · 지역 필터로 공연 검색  
> 👀 공연 상세 정보 및 판매처 바로가기  
> ❤️ 관심 공연 찜하기  
> 🏆 실시간 공연 랭킹 TOP 10 조회  
> ✍️ 관람한 공연 후기 작성  
> 🎫 QR 스캐너로 티켓 보관함 저장 (출시예정)  



<br>

## 💻 개발 환경

<p align="left">
<img src="https://img.shields.io/badge/Swift-6.0-ff69b4">
<img src="https://img.shields.io/badge/Xcode-16.0-blue">
<img src="https://img.shields.io/badge/iOS-18.0+-orange">
</p>

- **기간**: 2024.09 ~ 2024.10 (Ver 1.0) → 2026.01 ~ 2026.04 (Ver 2.0 리팩토링)  
- **인원**: iOS 1명, 디자이너 1명

<br>

## 🔧 아키텍처 및 기술 스택

- `SwiftUI` / `Combine` / `MapKit` / `AVFoundation`  
- `Clean Architecture` (Data / Domain / Presentation)  
- `Coordinator Pattern` + `MVI Pattern` + `MVVM + Combine`  
- `URLSession` + `Swift Concurrency` + `XML Parser`  
- `Firebase Firestore` / `Firebase Crashlytics`  
- `RealmSwift` / `UserDefault`  
- `Kingfisher`

<br>

## 🧰 프로젝트 주요 기술 사항

### 아키텍처 — Clean Architecture + Coordinator

```
Data         │ NetworkManager (URLSession + XML Parser)
             │ DataSource (Firebase Firestore / Realm / UserDefault)

─────────────┼──────────────────────────────────────────────────────
Domain       │ UseCase (UserUseCase / PerformanceUseCase)
             │ Model (PerformanceDisplayable, UserModel, ReviewModel …)

─────────────┼──────────────────────────────────────────────────────
Presentation │ Coordinator — 앱 전체 화면 흐름 단일 관리
             │ MVI (Home: Intent + State + Container)
             │ MVVM + Combine InOut (Search)
```

- **Coordinator Pattern**으로 Navigation · Sheet · Alert · Toast를 단일 객체에서 관리, 뷰 간 결합도 제거
- **MVI Pattern**: `Intent`(사용자 액션 처리) / `State`(@Observable 상태 보유) / `Container`(변경 이벤트 브릿지)로 데이터 흐름 단방향 일원화
- **UseCase**가 여러 DataSource를 조율해 비즈니스 로직을 캡슐화, 화면 코드는 단일 메서드 호출만으로 동작
- `ViewModeltype` Protocol + associatedtype 으로 MVVM 구조 명시적 정의
- `ViewModifier` / `extension` 활용으로 공통 UI 컴포넌트 캡슐화 및 재사용성 향상

<br>

### Swift Concurrency + XML Parser

- `async/await` 기반 네트워크 요청으로 에러 처리 명확화 및 Data Race 방지
- `async let` + `withTaskGroup`으로 홈 화면 다수 API를 병렬 처리해 응답 시간 단축
- KOPIS 공연 API의 XML 응답을 `XMLParserDelegate` 기반 커스텀 파서로 처리
- 파싱 후 DTO → Domain Model 매핑으로 네트워크 계층과 뷰 계층 간 결합도 최소화

<br>

### QR 티켓 스캐너 (출시예정)

- `AVFoundation`(AVCaptureSession)으로 카메라 프리뷰 구현
- QR 코드 스캔 결과를 `Realm`에 티켓 형태로 저장
- `UIViewRepresentable`로 카메라 프리뷰를 SwiftUI 환경에 통합

<br>

### Card-flip Animation 커스텀 티켓 뷰 (Ver 1.0 UI)

- `rotation3DEffect` + `scaleEffect`로 카드 뒤집기 효과 구현
- `animation` modifier로 앞·뒷면 전환 시 자연스러운 인터랙션 연출

<br>

### Firebase Crashlytics

- 런타임 크래시 및 오류를 실시간 모니터링하여 사용자 경험 저하 요인을 빠르게 감지 및 대응

<br>

## 🚨 트러블 슈팅

### 1. 런타임 시 과도한 메모리 사용

<div align="center">
    <table>
        <tr>
            <th>해결 전 메모리</th>
            <th>해결 후 메모리</th>
            <th>해결 전 이미지 용량</th>
            <th>해결 후 이미지 용량</th>
        </tr>
        <tr>
            <td><img width="120" src="https://github.com/user-attachments/assets/4f1ecfec-ee59-48b4-b195-fb995268fc3e"></td>
            <td><img width="120" src="https://github.com/user-attachments/assets/2a964cac-59d6-4a9a-a17d-aa3736376cab"></td>
            <td><img width="300" src="https://github.com/user-attachments/assets/edafc550-95d1-40c4-abef-c78fbe77b52e"></td>
            <td><img width="300" src="https://github.com/user-attachments/assets/fd7ceb9d-c910-4467-8fad-f5c8cbb59e2e"></td>
        </tr>
    </table>
</div>

**PROBLEM**  
공연 정보 API가 앱 UI 크기에 비해 과도한 해상도의 이미지를 반환해 런타임 메모리 사용량이 비정상적으로 높아지는 문제 확인

**SOLUTION**  
`Kingfisher`의 Image Resizing + DownSampling 옵션을 적용해 화면에 실제 표시되는 크기에 맞는 해상도로만 디코딩

**RESULT**  
이미지 용량 기준 **약 90% 감소**, 스크롤 시 메모리 급증 현상 해소

---

### 2. Firestore 다중 컬렉션 조율 및 랭킹 캐싱

**PROBLEM**  
리뷰 작성 하나의 액션이 `users` / `performances` / `app` 세 컬렉션을 각각 직접 수정해야 했고, Firestore 구조가 변경될 때마다 화면 코드 전반에 수정이 전파되는 유지보수 문제 발생.  
또한 랭킹 데이터를 매번 외부 KOPIS API에서 실시간 호출하여 초기 로딩이 느리고 API 호출 비용이 발생

**SOLUTION**
- **DataSource 분리**: 컬렉션마다 접근 책임을 `UserDataSource` / `PerformanceDataSource` / `AppDataSource`로 분리해 각 저장소가 자신의 역할만 수행하도록 설계
- **UseCase 캡슐화**: 리뷰 작성 등 비즈니스 로직은 `UserUseCase`가 여러 DataSource를 내부에서 조율, 화면 코드는 `writeReview(_:)` 단일 호출만으로 동작
- **랭킹 캐싱 전략**: 랭킹 데이터를 Firebase에 저장하고 마지막 갱신 시각을 함께 기록. 만료(24시간) 시에만 백그라운드 `Task`로 KOPIS API를 호출해 갱신하고, 사용자에게는 항상 캐시된 값을 즉시 반환

**RESULT**  
DB 구조 변경 시 수정 범위가 DataSource 내부로 국한되어 화면 코드 무수정. 랭킹 화면 초기 로딩 속도 개선 및 불필요한 외부 API 중복 호출 제거

---

### 3. 마이페이지 프로필 + 스티키 탭 헤더 구현

**PROBLEM**  
시스템 `.sheet`로 하단 목록을 표시하면 탭바를 가리는 UX 문제 발생.  
커스텀 드래그 시트로 대응하면 시트 드래그 제스처와 내부 스크롤 제스처가 충돌해 부자연스러운 동작이 반복됨.  
추가로 탭 헤더가 네비게이션 영역까지 올라왔을 때 뒤 콘텐츠가 비쳐 보이는 시각적 문제 및 `toolbarBackground`의 `LinearGradient` 미지원 한계 존재

**SOLUTION**
- **제스처 충돌 제거**: 단일 `ScrollView`로 전체 화면을 구성, 프로필 영역은 `Color.clear`로 높이만 확보한 뒤 `ZStack` 뒤에 고정 배치해 드래그 제스처를 ScrollView 하나가 독점하도록 처리
- **Sticky 탭 헤더**: `LazyVStack(pinnedViews: [.sectionHeaders])`의 Section header에 탭 헤더를 등록해 스크롤 시 상단 고정 효과 구현
- **헤더 배경 그라데이션**: `GeometryReader`로 헤더의 전역 Y좌표를 실시간 추적해, 네비게이션 영역에 진입하는 순간 헤더 배경에 그라데이션 이미지를 렌더링해 뒤 콘텐츠를 자연스럽게 가림
- **네비게이션 배경 처리**: `toolbarBackground`의 LinearGradient 미지원 한계를 우회하기 위해 네비게이션 배경을 별도 `Image` 뷰로 분리하고 `.ignoresSafeArea(edges: .top)` 적용해 SafeArea 경계 없이 자연스럽게 이어지도록 처리

**RESULT**  
제스처 충돌 없이 바텀시트가 올라오는 듯한 자연스러운 스크롤 UX 구현, 탭바 가림 문제 해소 및 네비게이션 영역까지 그라데이션이 끊김 없이 이어지는 화면 완성
