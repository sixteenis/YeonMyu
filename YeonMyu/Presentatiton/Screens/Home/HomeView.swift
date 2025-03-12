//
//  HomeView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 1/22/25.
//

import SwiftUI
import SwiftUIPullToRefresh

struct HomeView: View {
    @StateObject var container: Container<HomeIntentProtocol, HomeStateProtocol>
    private var intent: HomeIntentProtocol { container.intent }
    private var state: HomeStateProtocol { container.state }
    @State private var currentPage: Int = 1
    
    //@StateObject private var vm = HomeVM()
    @State private var isToolbarHidden = true // 탭바 숨김 유무
    @State private var isAreSelectedPresented = false //지역 선택 바텀시트 토글
    @MainActor private var navHeight = CGFloat.safeAreaTop + 12 + 28 + 12

    private let colors: [Color] = [.white, .blue, .green]
    @State private var segmentedPage: Int = 0
    @State private var stickyOffset: CGFloat = 0
    
    
    @State private var goSearchView = false
    
    @State var arePosition = ScrollPosition(edge: .leading) //지역 스크롤 상단
}
// MARK: - 빌드 부분
extension HomeView {
    static func build() -> some View {
        let state = HomeState()
        let intent = HomeIntent(state: state)
        
        let container = Container(
            intent: intent as HomeIntentProtocol,
            state: state as HomeStateProtocol,
            modelChangePublisher: state.objectWillChange
        )
        let view = HomeView(container: container)
        return view
    }
}

// MARK: - 화면 상태 변환
extension HomeView {
    @ViewBuilder
    var body: some View {
        NavigationStack {
            //지역 선택 바텀 시트
            ZStack {
                content()
                switch state.contentState {
                case .initView:
                    InitView()
                case .loading:
                    LoadingView()
                case .error:
                    EmptyView()
                default:
                    EmptyView()
                }
            }
            .ignoresSafeArea(edges: state.contentState == .initView ? .all : .top)
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(state.contentState == .initView ? .hidden : .automatic, for: .tabBar, .bottomBar)
            .task {
                intent.onAppear(city: state.selectedCity, prfCate: state.selectedPrfCate)
            }
            .navigationDestination(item: Binding(get: {state.selectedPost}, set: {_ in intent.postTapped(id: nil)})) { id in
                DetailView(postID: id) //공연 상세 뷰로 이동
            }
            .navigationDestination(item: Binding(get: {state.selectedUserInfo}, set: {_ in intent.userInfoTapped(info: nil)})) { id in
                SearchView() //사용자 기록 뷰로 이동
            }
            .navigationDestination(isPresented: $goSearchView) {
                SearchView() //검색 뷰로 이동
            }
        }
    }
}

// MARK: - 메인 화면
private extension HomeView {
    func content() -> some View {
        ZStack {
            mainContent()
                .vTop()
            if !isToolbarHidden {
                navView(false)
                    .vTop()
            }
        }
        .sheet(isPresented: $isAreSelectedPresented) {
            CitySelectBottomSheetView(selectedCity: state.selectedCity, compltionCity: Binding(get: {state.selectedCity}, set: {intent.areaTapped(area: $0, prfCate: state.selectedPrfCate)}))
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.45)]) //바텀시트 크기
            
        }
    }
    func mainContent() -> some View {
        RefreshableScrollView(onRefresh: { done in
            intent.refreshAll() //새로고침
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred() //햅틱 피드백
            done()
        }) {
            ZStack {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    VStack {
                        topBannerView(state.headerPosts)
                            .frame(height: 500)
                            .onScrollVisibilityChange(threshold: 0.999999) { isVisible in
                                print(isVisible)
                                isToolbarHidden = isVisible
                            }
                        searchView()
                            .frame(height: 50)
                            .padding(24)
                        infoHeaderView()
                        inforView()
                            .frame(height: 120)
                            .padding(.horizontal, 22)
                            .padding(.vertical, 6)
                            .padding(.bottom, 48)
                    } //:VSTACK
                    Section(header: GeometryReader { geometry in
                        stickyHeader()
                            .onChange(of: geometry.frame(in: .global).minY) { oldValue, newValue in
                                stickyOffset = newValue
                            }
                            .offset(y: max(stickyOffset <= navHeight ? navHeight - stickyOffset : 0, 0))
                    }) {
                        switch segmentedPage {
                        case 0: playView()
                        case 1: playView()
                        case 2: playView()
                        default: playView()
                        }
                    }
                }//:LazyVSTACK
                navView(true) //투명 네비게이션 뷰
                    .vTop()
            } //:ZSTACK
        } //:SCROLL
        .scrollIndicators(.hidden)
    }
}

// MARK: - 상단 네비게이션 부분
private extension HomeView {
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
                
                alert(isOpacity ? Color.asWhite : Color.asGray200)
                    .hTrailing()
                    .vBottom()
                    .padding(.bottom, 12)
                    .padding(.trailing)
            }
    }
    func alert(_ color: Color) -> some View {
        Image.asBell
            .resizable()
            .frame(width: 28, height: 28)
            .foregroundStyle(color)
            .overlay {
                asText("9")
                    .font(.boldFont8)
                    .foregroundStyle(Color.white)
                    .background(
                        Circle()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color.asPurple300)
                    )
                    .offset(x: 6, y: -4)
                
            }
    }
    
}
// MARK: - 상단 페이지 뷰 부분
private extension HomeView {
    //상단 공연 정보 컬렉션 뷰
    func topBannerView(_ posts: [MainHeaderPlayModel]) -> some View {
        ZStack(alignment: .bottomLeading) {
            TabView(selection: $currentPage) {
                // 가짜 마지막 페이지 (posts.count - 1)
                if let firstPost = posts.first {
                    bannerView(firstPost)
                        .tag(0)
                }
                
                // 실제 페이지들
                ForEach(posts.indices, id: \.self) { index in
                    bannerView(posts[index])
                        .tag(index + 1)
                        
                }
                
                // 가짜 첫 페이지 (index 0)
                if let lastPost = posts.last {
                    bannerView(lastPost)
                        .tag(posts.count + 1)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: currentPage) { oldValue, newValue in
                // 첫 번째 페이지와 마지막 페이지 사이에서 끊어짐 현상 방지
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if newValue == 0 {
                        currentPage = posts.count // 마지막 페이지로 순간 이동
                    } else if newValue == posts.count + 1 {
                        currentPage = 1 // 첫 페이지로 순간 이동
                    }
                }
            }
            // 커스텀 페이지 점 표시
            HStack {
                ForEach(posts.indices, id: \.self) { index in
                    Circle()
                        .fill((index + 1) == currentPage ? Color.white.opacity(80) : Color.white.opacity(30))
                        .frame(width: 10, height: 10)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 33)
        }
    }
    //상단 공연 정보 뷰
    func bannerView(_ post: MainHeaderPlayModel) -> some View {
        ZStack {
            ZStack {
                CustomPostImage(url: post.postURL)
                //.tag(index) // 각 페이지를 고유 태그로 설정
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .asBlack.opacity(0.6), location: 0.2),  // 0% → 검정(0.6)
                        .init(color: .asBlack.opacity(0.2), location: 0.47),  // 70% → 검정(0.2)
                        .init(color: .asPurple300, location: 1.0)         // 100% → 보라색
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                Rectangle()
                    .foregroundStyle(Color.asBlack.opacity(0.25))
            }
            VStack(alignment: .leading) {
                asText(post.mainTitle)
                    .foregroundStyle(Color.asWhite)
                    .font(.boldFont28)
                    .padding(.bottom, 4)
                    .shadow(color: Color.asBlack.opacity(0.25), radius: 4, x: 0, y: 0)
                asText(post.subTitle)
                    .foregroundStyle(Color.asPurple500)
                    .font(.font16)
                    .shadow(color: Color.asBlack.opacity(0.25), radius: 4, x: 0, y: 0)
            } //:VSTACK
            .vBottom()
            .hLeading()
            .padding(.bottom, 65)
            .padding(.leading, 24)
            .wrapToButton { //포스터 클릭 시
                print(post.postID)
                intent.postTapped(id: post.postID)
            }
        }
    }
}

// MARK: - 검색 뷰 부분
private extension HomeView {
    func searchView() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color.asMainSecondaryPurple, lineWidth: 1.5)
            .fill(Color.clear)
            .overlay(
                HStack {
                    Image.search
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.asMainPurple)
                        .padding(.horizontal)
                    
                    asText("보고 싶은 공연 이름을 검색하세요")
                        .font(.font14)
                        .foregroundStyle(Color.asGray300)
                    Spacer()
                }
            )
            .wrapToButton {
                self.goSearchView.toggle()
            }
        
        
    }
}
// MARK: - 사용자 커스텀 현황 부분
private extension HomeView {
    func infoHeaderView() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 0) {
                asText("서연")
                    .foregroundColor(.asMainSecondaryPurple) // 닉네임의 색상 변경
                    .font(.boldFont20)
                asText("님의 공연 기록")
                    .foregroundColor(.asFont) // 나머지 텍스트 색상
                    .font(.boldFont20)
            } //:HSTACK
            asText("궁금한 기록을 눌러서 확인해보세요!")
                .foregroundColor(.asGray200)
                .font(.font14)
        } //:VSTACK
        .hLeading()
        .padding(.leading, 24)
    }
    
    func inforView() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.asMainPurpleBorder)
            .stroke(Color.asMainPurpleBorderLine, lineWidth: 1.5)
            .overlay{
                HStack(spacing: 0) {
                    oneInforView(title: "찜한 공연", logo: Image.asHeart, result: "10")
                        .frame(maxWidth: .infinity)
                        .wrapToButton {
                            intent.userInfoTapped(info: .liikes)
                        }
                    inforLine()
                    oneInforView(title: "관람한 공연", logo: Image.asperformance, result: "2")
                        .frame(maxWidth: .infinity)
                        .wrapToButton {
                            intent.userInfoTapped(info: .recodePlayCnt)
                        }
                    inforLine()
                    oneInforView(title: "예정된 티켓", logo: Image.asCircleTicket, result: "1")
                        .frame(maxWidth: .infinity)
                        .wrapToButton {
                            intent.userInfoTapped(info: .schedulePlayCnt)
                        }
                }
            }
    }
    
    func oneInforView(title: String, logo: Image, result: String) -> some View {
        Rectangle()
            .fill(Color.clear)
            .overlay {
                VStack {
                    logo
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Color.asPurple300)
                    asText(title)
                        .asForeground(Color.asTextColor)
                        .font(.font12)
                    
                    asText(result)
                        .asForeground(Color.asTextColor)
                        .font(.boldFont28)
                }
            }
    }
    
    func inforLine() -> some View {
        Rectangle()
            .frame(width: 1)
            .asForeground(Color.asMainPurpleBorderLine)
            .padding([.top, .bottom], 15)
    }
    
}
// MARK: - 하단
private extension HomeView {
    func stickyHeader() -> some View {
        VStack {
            CustomSegmentedView(segments: state.playCategorys.map { $0.title},
                                currentPage: Binding(get: {state.selectedPrfCate.rawValue}, set: {intent.playCategoryTapped($0, city: state.selectedCity, prfCate: state.playCategorys[$0])}))
        }
        .background(Color.white) // Background를 추가하여 scroll 영역과 일치 시킴
    }
    func playView() -> some View {
        VStack {
            recommendHeaderView()
                .hLeading()
                .padding(24)
                .padding(.top, 36)
            
            recommendCollectionView(state.areaTopPrf)
            
            randomHeaderView(main: state.randomPrfs.mainTitle, sub: state.randomPrfs.subTitle)
                .padding(24)
            randomTableView(state.randomPrfs.simplePlayData)
        }
    }
    //가로 스크롤 공연 추천 헤더 부분
    func recommendHeaderView() -> some View {
        VStack(alignment: .leading) {
            HStack {
                HStack {
                    asText(state.selectedCity.rawValue)
                    Image.downArrow
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(Color.asPurple300)
                        .rotationEffect(.degrees(isAreSelectedPresented ? 180 : 0)) // 180도 회전
                        .animation(.easeInOut(duration: 0.25), value: isAreSelectedPresented) // 애니메이션 적용
                }
                .font(.boldFont20)
                .foregroundStyle(Color.asMainPurple)
                .padding(.leading, 10) // 좌우 여백 추가
                .padding(.trailing, 5) // 좌우 여백 추가
                .padding(.vertical, 3)   // 상하 여백 추가
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                        .stroke(Color.asMainPurple, lineWidth: 2)
                )
                .wrapToButton {
                    self.isAreSelectedPresented.toggle()
                }
                
                asText("주변의 추천 공연")
                    .font(.boldFont20)
            } //:HSTACK
            asText("내 지역을 선택해 맞춤 공연을 추천받아 보세요!")
                .font(.font14)
                .foregroundStyle(Color.asGray200)
        }
    }
    //가로 스크롤 공연 추천 뷰
    func recommendCollectionView(_ posts: [SimplePostModel]) -> some View {
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(posts, id: \.id) { post in
                    CustomHorizontalPlayView(post: post)
                        .frame(width: 120, height: 230)
                        .padding(.leading, 24)
                        .wrapToButton {
                            intent.postTapped(id: post.postId)
                        }
                }
            }
        } //가로 스크롤 부분
        .scrollPosition($arePosition)
        .onChange(of: state.selectedPrfCate) { oldValue, newValue in
            arePosition.scrollTo(edge: .leading) //공연 종류 변경 시
        }
        .onChange(of: state.selectedCity) { oldValue, newValue in
            arePosition.scrollTo(edge: .leading) //지역 변경 시
        }
    
    }
    
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
            Image.rightArrow
                .resizable()
                .foregroundStyle(Color.asGray300)
                .frame(width: 24, height: 24)
        }
    }
    
    func randomTableView(_ data: [SimplePostModel]) -> some View {
        VStack {
            ForEach(data, id: \.id) { post in
                CustomVerticalPlayView(post: post)
                    .frame(height: 80)
                    .padding([.leading, .bottom], 24)
                    .wrapToButton {
                        intent.postTapped(id: post.postId)
                    }
            }
        }
    }
}
// MARK: - 티켓 정보 뷰

#Preview {
    HomeView.build()
}
