//
//  HomeVM.swift
//  YeonMyu
//
//  Created by 박성민
//

import Foundation
import Combine
import SwiftUI

/// 홈 화면 ViewModel - Input/Output MVVM 패턴
/// SearchVM, StorageVM과 동일한 ViewModeltype 프로토콜을 준수합니다.
final class HomeVM: ViewModeltype, ErrorRoutable {

    // MARK: - ViewModeltype 준수 프로퍼티
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output = Output()

    // MARK: - 의존성
    private let perfUseCase = PerformanceUseCase()
    /// 화면 전환을 담당하는 Coordinator (View에서 onAppear 시 주입)
    var coordinator: MainCoordinator?
    /// 전역 에러 라우팅 핸들러 (View에서 onAppear 시 주입)
    var globalErrorHandler: GlobalErrorHandler?
    /// 로컬 스코프 에러 (notFound, decodingFailed 등)
    /// - route(_:) 가 자동 세팅. View 는 SwiftUI 표준 .alert(isPresented:error:) 로 바인딩.
    /// - 가공이 필요하면 didSet 으로 분기.
    @Published var localError: AppError?
    /// 헤더 Top1 공연 조회 시 사용되는 유저 도시 정보
    private var userCity: CityCode = .all

    init() {
        self.cancellables = Set<AnyCancellable>()
        transform()
    }
    // MARK: - transform: Input 이벤트를 Output 상태로 변환
    func transform() {

        // 뷰 진입 시 유저 정보 설정 및 초기 데이터 로드
        // - 이미 .content 상태인 경우 중복 네트워크 요청 방지
        input.onAppear
            .sink { [weak self] (name, city) in
                guard let self else { return }
                self.output.userName = name
                self.output.selectedCity = city
                self.userCity = city
                guard self.output.contentState != .content else { return }
                self.loadInitialData()
                self.loadRecentReviews()
            }.store(in: &cancellables)

        // 당기기 새로고침 시 헤더 포스터 데이터 재로드
        input.refresh
            .sink { [weak self] in
                guard let self else { return }
                self.output.contentState = .loading
                Task {
                    do {
                        let headerPosts = try await self.fetchHeaderPostData()
                        await MainActor.run {
                            self.applyHeaderPosts(headerPosts)
                            self.output.contentState = .content
                        }
                    } catch {
                        await MainActor.run {
                            self.route(error)
                        }
                    }
                }
            }.store(in: &cancellables)

        // 공연 포스터 클릭 시 상세 화면으로 이동
        input.postTapped
            .sink { [weak self] id in
                self?.coordinator?.push(.playDetail(mt20id: id))
            }.store(in: &cancellables)

        // 공연 종류 탭 선택 시 인덱스로 PrfCate를 결정하고 공연 목록 갱신
        input.playCategoryTapped
            .sink { [weak self] index in
                guard let self else { return }
                let prfCate = PrfCate.allCases[index]
                self.output.selectedPrfCate = prfCate
                Task {
                    do {
                        let posts = try await self.fetchUserAreaPlayList(
                            area: self.output.selectedCity,
                            prfCate: prfCate,
                            page: 1
                        )
                        await MainActor.run {
                            self.output.areaTopPrf = posts
                        }
                    } catch {
                        await MainActor.run {
                            self.route(error)
                        }
                    }
                }
            }.store(in: &cancellables)

        // 지역 선택 시 selectedCity 업데이트 후 해당 지역의 공연/헤더/Top10 갱신
        // - userCity는 fetchHeaderPostData / fetchTop10WithArea의 입력으로 사용되므로 함께 갱신해야 한다
        input.areaTapped
            .sink { [weak self] city in
                guard let self else { return }
                self.output.selectedCity = city
                self.userCity = city
                Task {
                    do {
                        async let posts = self.fetchUserAreaPlayList(
                            area: city,
                            prfCate: self.output.selectedPrfCate,
                            page: 1
                        )
                        async let headerPosts = self.fetchHeaderPostData()
                        async let top10 = self.fetchTop10WithArea()

                        let (a, h, t) = try await (posts, headerPosts, top10)
                        await MainActor.run {
                            self.output.areaTopPrf = a
                            self.applyHeaderPosts(h)
                            if let t { self.output.top10Prfs = t }
                        }
                    } catch {
                        await MainActor.run {
                            self.route(error)
                        }
                    }
                }
            }.store(in: &cancellables)

        // 검색 버튼 클릭 시 검색 화면으로 이동
        input.searchTapped
            .sink { [weak self] in
                self?.coordinator?.push(.search)
            }.store(in: &cancellables)

        // 최근 리뷰 아이템 클릭 시 리뷰 상세 화면으로 이동
        input.reviewTapped
            .sink { [weak self] review in
                self?.coordinator?.push(.reviewDetailView(reviewInfo: review, isShowMovePerfInfo: true))
            }.store(in: &cancellables)

        // 도시 선택 바텀시트 표시 요청 시 Coordinator를 통해 시트 표시
        // - isCitySelectPresented는 화살표 회전 애니메이션에 사용됨
        // - Binding 클로저는 sheet가 coordinator에 보관되는 동안 self를 잡으므로 [weak self]로 retain cycle 방지
        input.citySelectTapped
            .sink { [weak self] in
                guard let self else { return }
                self.output.isCitySelectPresented = true
                let cityBinding = Binding<CityCode>(
                    get: { [weak self] in self?.output.selectedCity ?? .seoul },
                    set: { [weak self] in self?.input.areaTapped.send($0) }
                )
                self.coordinator?.presentSheet(.citySelect(
                    binding: cityBinding,
                    onDismiss: { [weak self] in
                        self?.output.isCitySelectPresented = false
                    }
                ))
            }.store(in: &cancellables)
    }
}

// MARK: - 초기 데이터 로드
private extension HomeVM {

    /// 홈 화면 최초 진입 시 모든 공연 데이터를 병렬로 로드합니다.
    func loadInitialData() {
        Task {
            do {
                // async let으로 병렬 네트워크 요청
                async let headerPosts  = fetchHeaderPostData()
                async let areaTopPrf   = fetchUserAreaPlayList(area: output.selectedCity, prfCate: output.selectedPrfCate, page: 1)
                async let nowOpen      = fetchNowOpenPrfs()
                async let openrun      = fetchOpenrunPrfs()
                async let top10        = fetchTop10WithArea()

                let (h, a, n, o, t) = try await (headerPosts, areaTopPrf, nowOpen, openrun, top10)

                await MainActor.run {
                    applyHeaderPosts(h)
                    output.areaTopPrf = a
                    if let n { output.randomPrfs = n }
                    if let o { output.openrunPrfs = o }
                    if let t { output.top10Prfs = t }
                    output.contentState = .content
                }
            } catch {
                await MainActor.run {
                    self.output.contentState = .error
                    self.route(error)
                }
            }
        }
    }

    /// 최근 리뷰 목록을 Firebase에서 불러옵니다.
    func loadRecentReviews() {
        Task {
            do {
                let reviews = try await PerformanceUseCase().getRecentReviewList()
                await MainActor.run {
                    output.recentReview = reviews
                }
            } catch {
                await MainActor.run {
                    self.route(error)
                }
            }
        }
    }

    /// 헤더 포스터 데이터를 output에 적용합니다.
    /// - 무한 캐러셀 구현을 위해 원본 데이터를 10회 복제하여 headerPostsTmp에 저장
    func applyHeaderPosts(_ posts: [MainHeaderPlayModel]) {
        output.headerPosts = posts
        output.headerPostsTmp = []
        for _ in 0..<10 {
            output.headerPostsTmp.append(contentsOf: posts)
        }
    }
}

private extension HomeVM {
    /// 상단 캐러셀에 표시할 랜덤 헤더 포스터 데이터를 병렬로 조회합니다.
    /// - 오픈 공연, 올해/작년 수상작, 지역 Top1 중 랜덤 셔플하여 반환
    func fetchHeaderPostData() async throws -> [MainHeaderPlayModel] {
        let requests: [() async throws -> MainHeaderPlayModel?] = [
            perfUseCase.fetchNowOpenPrf,
            perfUseCase.fetchNowYearAwardPrf,
            perfUseCase.fetchLastYearAwardPrf,
            { try await self.perfUseCase.fetchTop1HeaderPost(city: self.userCity) }
        ]

        let resultArray = await withTaskGroup(of: MainHeaderPlayModel?.self) { group in
            for request in requests {
                group.addTask { try? await request() }
            }
            var postData: [MainHeaderPlayModel] = []
            for await data in group {
                if let data { postData.append(data) }
            }
            return postData
        }
        return resultArray.shuffled()
    }

    /// 선택된 지역 및 공연 종류에 해당하는 공연 목록을 조회합니다.
    func fetchUserAreaPlayList(area: CityCode, prfCate: PrfCate, page: Int) async throws -> [SimplePostModel] {
        try await perfUseCase.fetchUserAreaPlayList(area: area, prfCate: prfCate, page: page)
    }

    /// 곧 상영 예정인 공연 랜덤 목록을 조회합니다.
    func fetchNowOpenPrfs() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchNowOpenPrfs()
    }

    /// 오픈런 중인 공연 랜덤 목록을 조회합니다.
    func fetchOpenrunPrfs() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchOpenrunPrfs()
    }

    /// 유저 지역 기준 인기 Top10 공연 목록을 조회합니다.
    func fetchTop10WithArea() async throws -> RandomSimplePlayModel? {
        try await perfUseCase.fetchTop10WithArea(city: userCity)
    }
}
// MARK: - 이벤트 모음
extension HomeVM {
    struct Input {
        var onAppear = PassthroughSubject<(String, CityCode), Never>()
        var refresh = PassthroughSubject<Void, Never>()
        var postTapped = PassthroughSubject<String, Never>()
        var playCategoryTapped = PassthroughSubject<Int, Never>()
        var areaTapped = PassthroughSubject<CityCode, Never>()
        var searchTapped = PassthroughSubject<Void, Never>()
        var reviewTapped = PassthroughSubject<ReviewModel, Never>()
        var citySelectTapped = PassthroughSubject<Void, Never>()
    }
}

// MARK: - 상태 모음
extension HomeVM {
    struct Output {

        /// 뷰 로딩 상태 (.initView / .loading / .content / .error)
        var contentState: ContentState = .initView

        /// 상단 캐러셀에 표시되는 포스터 원본 데이터
        var headerPosts: [MainHeaderPlayModel] = []

        /// 무한 캐러셀 구현을 위해 원본 데이터를 10회 복제한 포스터 데이터
        var headerPostsTmp: [MainHeaderPlayModel] = []

        /// 공연 종류 탭 목록 (PrfCate.allCases)
        var playCategorys: [PrfCate] = PrfCate.allCases

        /// 선택된 지역의 추천 공연 목록 (가로 스크롤)
        var areaTopPrf: [SimplePostModel] = []

        /// 곧 상영 예정인 공연 랜덤 목록
        var randomPrfs: RandomSimplePlayModel = RandomSimplePlayModel(mainTitle: "", subTitle: "", simplePlayData: [])

        /// 오픈런 중인 공연 랜덤 목록
        var openrunPrfs: RandomSimplePlayModel = RandomSimplePlayModel(mainTitle: "", subTitle: "", simplePlayData: [])

        /// 유저 지역 기준 인기 Top10 공연 목록
        var top10Prfs: RandomSimplePlayModel = RandomSimplePlayModel(mainTitle: "", subTitle: "", simplePlayData: [])

        /// 현재 선택된 지역
        var selectedCity: CityCode = .seoul

        /// 현재 선택된 공연 종류
        var selectedPrfCate: PrfCate = .all

        /// 유저 닉네임
        var userName: String = ""

        /// Firebase에서 불러온 최근 리뷰 목록
        var recentReview: [ReviewModel] = []

        /// 도시 선택 바텀시트 표시 여부
        /// - true일 때 지역 버튼의 화살표 아이콘이 180도 회전
        var isCitySelectPresented: Bool = false
    }
}

