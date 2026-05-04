//
//  HomeView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 1/22/25.
//

import SwiftUI
import SwiftUIPullToRefresh

struct HomeView: View {
    @Environment(MainCoordinator.self) var coordinator   // Coordinator 주입
    @Environment(UserUseCase.self) private var userUseCase
    @Environment(DIContainer.self) private var container // 전역 의존성 컨테이너
    @StateObject private var vm = HomeVM()                // MVVM ViewModel

    // MARK: - 순수 UI 상태
    @State private var currentIndex: Int = 0             // 상단 캐러셀 현재 페이지
    @State private var isToolbarHidden = true            // 투명 네비게이션 표시 여부
    @State private var stickyOffset: CGFloat = 0         // 스티키 헤더 오프셋
    @State var arePosition = ScrollPosition(edge: .leading) // 지역 추천 스크롤 위치
}

// MARK: - 화면 상태 전환
extension HomeView {
    @ViewBuilder
    var body: some View {
        ZStack {
            content()
            // 뷰 로딩 상태에 따른 오버레이
            switch vm.output.contentState {
            case .initView:
                InitView()
                    .ignoresSafeArea(.all)
                    .toolbar(.hidden, for: .tabBar)
            case .loading:
                LoadingView()
            default:
                EmptyView()
            }
        }
        .onAppear {
            // Coordinator 주입 및 초기 유저 정보 전달
            vm.coordinator = coordinator
            vm.globalErrorHandler = container.globalErrorHandler
            vm.input.onAppear.send((userUseCase.userInfo.name, userUseCase.userInfo.getCityCode()))
        }
        .onChange(of: vm.output.headerPostsTmp) { _, _ in
            // 무한 캐러셀 구현을 위해 데이터 로드 후 중간 인덱스로 초기화
            currentIndex = vm.output.headerPostsTmp.count / 2
        }
        // 로컬 스코프 에러 (notFound, decodingFailed 등) — SwiftUI 표준 alert API
        // AppError 가 LocalizedError 채택해서 errorDescription 자동 노출.
        .alert(
            isPresented: Binding(
                get: { vm.localError != nil },
                set: { if !$0 { vm.localError = nil } }
            ),
            error: vm.localError
        ) { _ in
            Button("확인") { vm.localError = nil }
        } message: { _ in
            EmptyView()
        }
    }
}

// MARK: - 메인 화면
private extension HomeView {
    func content() -> some View {
        ZStack {
            mainContent()
                .vTop()
            // 스크롤 시 불투명 네비게이션 뷰 표시
            if !isToolbarHidden {
                navView(false)
                    .vTop()
            }
        }
    }

    func mainContent() -> some View {
        RefreshableScrollView(onRefresh: { done in
            vm.input.refresh.send() // 새로고침
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred() // 햅틱 피드백
            done()
        }) {
            ZStack {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    VStack {
                        // 상단 캐러셀 (데이터가 있는 경우에만 표시)
                        if !vm.output.headerPosts.isEmpty {
                            topCarouselView()
                                .frame(height: 500)
                        }

                        // 검색 바
                        searchView()
                            .frame(height: 50)
                            .padding(24)

                        // 최근 리뷰 섹션 (데이터가 있는 경우에만 표시)
                        if !vm.output.recentReview.isEmpty {
                            infoHeaderView()
                            inforView()
                                .padding(.vertical, 6)
                                .padding(.bottom, 24)
                        }
                    }

                    // 공연 종류 탭 + 공연 목록 섹션 (스티키 헤더 적용)
                    Section(header: GeometryReader { geometry in
                        stickyHeader()
                            .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                                stickyOffset = newValue
                            }
                            .offset(y: max(stickyOffset <= navHeight ? navHeight - stickyOffset : 0, 0))
                    }) {
                        playView()
                    }
                }

                // 반투명 네비게이션 뷰 (항상 최상단)
                navView(true)
                    .vTop()
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - 상단 네비게이션 뷰
private extension HomeView {
    /// 투명도에 따라 배경색과 로고 색상이 달라지는 네비게이션 바
    /// - Parameter isOpacity: true이면 반투명, false이면 불투명
    @ViewBuilder
    func navView(_ isOpacity: Bool) -> some View {
        Rectangle()
            .foregroundStyle(Color.asWhite)
            .opacity(isOpacity ? 0.3 : 1)
            .frame(height: navHeight)
            .overlay {
                Image.logoM
                    .resizable()
                    .foregroundStyle(isOpacity ? Color.asWhite : Color.asPurple300)
                    .frame(width: 127.7, height: 26)
                    .hLeading()
                    .vBottom()
                    .padding([.top, .bottom], 12)
                    .padding(.leading)
            }
    }
}

// MARK: - 상단 캐러셀 뷰
private extension HomeView {
    /// 무한 스크롤 캐러셀 뷰
    /// - headerPostsTmp(원본 * 10)를 TabView로 표시하여 무한 스크롤 효과 구현
    func topCarouselView() -> some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(vm.output.headerPostsTmp.indices, id: \.self) { index in
                    let item = vm.output.headerPostsTmp[index]

                    ZStack {
                        PosterImageView(url: item.postURL)

                        // 그라디언트 오버레이
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .asBlack.opacity(0.6), location: 0.2),
                                .init(color: .asBlack.opacity(0.2), location: 0.47),
                                .init(color: .asPurple300, location: 1.0)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )

                        Rectangle()
                            .foregroundStyle(Color.asBlack.opacity(0.25))

                        // 공연 타이틀 및 서브 타이틀
                        VStack(alignment: .leading) {
                            asText(item.mainTitle)
                                .foregroundStyle(Color.asWhite)
                                .font(.boldFont28)
                                .multilineTextAlignment(.leading)
                                .padding(.bottom, 4)
                                .shadow(color: Color.asBlack.opacity(0.25), radius: 4)

                            asText(item.subTitle)
                                .foregroundStyle(Color.asPurple500)
                                .font(.font16)
                                .shadow(color: Color.asBlack.opacity(0.25), radius: 4)
                        }
                        .vBottom()
                        .hLeading()
                        .padding(.bottom, 65)
                        .padding(.leading, 24)
                    }
                    .frame(width: UIScreen.main.bounds.width, height: 500)
                    .tag(index)
                    .onTapGesture {
                        // 포스터 탭 시 상세 화면으로 이동
                        vm.input.postTapped.send(item.postID)
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 500)
            .animation(.easeInOut(duration: 0.25), value: currentIndex)

            // 커스텀 페이지 인디케이터
            HStack {
                ForEach(vm.output.headerPosts.indices, id: \.self) { index in
                    let isSelected = index == currentIndex % max(vm.output.headerPosts.count, 1)
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.6) : Color.white.opacity(0.25))
                        .frame(width: isSelected ? 18 : 8, height: 8)
                        .shadow(color: .asBlack.opacity(0.25), radius: 1.35)
                        .animation(.easeInOut(duration: 0.25), value: currentIndex)
                }
            }
            .vBottom()
            .hLeading()
            .padding(.horizontal, 28)
            .padding(.bottom, 33)
        }
        .onScrollVisibilityChange(threshold: 0.999999) { isVisible in
            // 캐러셀이 화면에서 벗어나면 불투명 네비게이션 뷰 표시
            isToolbarHidden = isVisible
        }
    }
}

// MARK: - 검색 바 뷰
private extension HomeView {
    /// 검색 화면으로 이동하는 더미 검색 바
    func searchView() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color.purpleBlueGradient, lineWidth: 1.5)
            .fill(Color.clear)
            .overlay(
                HStack(spacing: 0) {
                    Image.search
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.asMainPurple)
                        .padding(.leading, 14)
                        .padding(.trailing, 10)

                    asText("보고 싶은 공연 이름을 검색하세요")
                        .font(.font14)
                        .foregroundStyle(Color.asGray300)
                    Spacer()
                }
            )
            .wrapToButton {
                // 검색 버튼 탭 시 검색 화면으로 이동
                vm.input.searchTapped.send()
            }
    }
}

// MARK: - 최근 리뷰 섹션
private extension HomeView {
    /// 최근 리뷰 섹션 헤더
    func infoHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                asText("따끈따끈! New 공연 후기")
                    .foregroundColor(.asFont)
                    .font(.boldFont20)
            }
            asText("다른 사용자들의 실시간 리뷰를 확인해 보세요!")
                .foregroundColor(.asGray200)
                .font(.font14)
        }
        .hLeading()
        .padding(.leading, 24)
    }

    /// 최근 리뷰 가로 스크롤 목록
    func inforView() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(vm.output.recentReview) { review in
                    MyReviewView(review: review) {
                        // 리뷰 탭 시 상세 화면으로 이동
                        vm.input.reviewTapped.send(review)
                    }
                    .padding(.vertical, 5)
                    .frame(width: UIScreen.main.bounds.width - 48)
                    .containerRelativeFrame(.horizontal)
                    .scrollTransition { content, phase in
                        content.opacity(phase.isIdentity ? 1 : 0.6)
                    }
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .contentMargins(.horizontal, 24, for: .scrollContent)
    }
}

// MARK: - 하단 공연 목록 섹션
private extension HomeView {
    /// 공연 종류 탭이 있는 스티키 헤더
    func stickyHeader() -> some View {
        VStack {
            CustomSegmentedView(
                segments: vm.output.playCategorys.map { $0.title },
                currentPage: Binding(
                    get: { vm.output.selectedPrfCate.rawValue },
                    // 탭 선택 시 인덱스를 VM으로 전달
                    set: { vm.input.playCategoryTapped.send($0) }
                )
            )
        }
        .background(Color.white)
    }

    /// 지역별 추천 공연 + 랜덤 공연 목록을 포함하는 메인 콘텐츠 뷰
    func playView() -> some View {
        VStack {
            // 지역 선택 + 추천 공연 헤더
            recommendHeaderView()
                .hLeading()
                .padding(24)
                .padding(.top, 36)

            // 지역 추천 공연 목록 (가로 스크롤)
            if vm.output.areaTopPrf.isEmpty {
                PostEmptyView(infoText: "선택한 지역에 상영 중인 공연이 없습니다.")
                    .padding(.bottom, 20)
            } else {
                recommendCollectionView(vm.output.areaTopPrf)
                    .padding(.bottom, 20)
            }

            sectionDivider

            // 곧 상영 예정 공연 섹션
            randomHeaderView(main: vm.output.randomPrfs.mainTitle, sub: vm.output.randomPrfs.subTitle)
                .padding(24)
            randomTableView(vm.output.randomPrfs.simplePlayData)

            sectionDivider

            // 오픈런 공연 섹션
            randomHeaderView(main: vm.output.openrunPrfs.mainTitle, sub: vm.output.openrunPrfs.subTitle)
                .padding(24)
            randomTableView(vm.output.openrunPrfs.simplePlayData)

            sectionDivider

            // 지역 인기 Top10 섹션
            randomHeaderView(main: vm.output.top10Prfs.mainTitle, sub: vm.output.top10Prfs.subTitle)
                .padding(24)
            randomTableView(vm.output.top10Prfs.simplePlayData)

            SourceAndAppInfoView()
        }
    }

    /// 지역 선택 버튼과 추천 공연 안내 텍스트가 있는 헤더
    func recommendHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    asText(vm.output.selectedCity.rawValue)
                    Image.downArrow
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.asPurple300)
                        // 바텀시트가 표시 중일 때 화살표 180도 회전
                        .rotationEffect(.degrees(vm.output.isCitySelectPresented ? 180 : 0))
                        .animation(.easeInOut(duration: 0.15), value: vm.output.isCitySelectPresented)
                        .padding(.leading, 2)
                        .padding(.trailing, 4)
                }
                .font(.boldFont20)
                .foregroundStyle(Color.asMainPurple)
                .padding(.leading, 10)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                        .stroke(Color.asMainPurple, lineWidth: 2)
                )
                .wrapToButton {
                    // 지역 선택 바텀시트 표시 요청
                    vm.input.citySelectTapped.send()
                }

                asText("주변의 추천 공연")
                    .font(.boldFont20)
                    .padding(.leading, 5)
            }
            asText("내 지역을 선택해 맞춤 공연을 추천받아 보세요!")
                .font(.font14)
                .foregroundStyle(Color.asGray200)
                .padding([.horizontal, .top], 4)
        }
    }

    /// 지역 추천 공연 가로 스크롤 목록
    /// - 공연 종류 또는 지역 변경 시 자동으로 스크롤 위치를 처음으로 이동
    func recommendCollectionView(_ posts: [SimplePostModel]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(posts, id: \.id) { post in
                    HorizontalPerformanceView(post: post)
                        .frame(width: 120, height: 240)
                        .padding(.horizontal, 12)
                        .wrapToButton {
                            vm.input.postTapped.send(post.mt20id)
                        }
                }
            }
        }
        .padding(.horizontal, 12)
        .scrollPosition($arePosition)
        .onChange(of: vm.output.selectedPrfCate) { _, _ in
            // 공연 종류 변경 시 스크롤 위치 초기화
            arePosition.scrollTo(edge: .leading)
        }
        .onChange(of: vm.output.selectedCity) { _, _ in
            // 지역 변경 시 스크롤 위치 초기화
            arePosition.scrollTo(edge: .leading)
        }
    }

    /// 랜덤 공연 섹션 헤더 (메인 타이틀 + 서브 타이틀)
    func randomHeaderView(main: String, sub: String) -> some View {
        HStack(alignment: .top) {
            VStack(spacing: 4) {
                asText(main)
                    .font(.boldFont20)
                    .foregroundStyle(Color.asTextColor)
                    .hLeading()
                asText(sub)
                    .font(.font14)
                    .foregroundStyle(Color.asGray200)
                    .hLeading()
            }
            Spacer()
        }
    }

    /// 랜덤 공연 목록 (세로 리스트)
    func randomTableView(_ data: [SimplePostModel]) -> some View {
        LazyVStack {
            ForEach(data, id: \.id) { post in
                VerticalPerformanceView(post: post)
                    .padding(.leading, 24)
                    .padding(.bottom, 8)
                    .wrapToButton {
                        vm.input.postTapped.send(post.mt20id)
                    }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(MainCoordinator())
        .environment(UserUseCase())
}
