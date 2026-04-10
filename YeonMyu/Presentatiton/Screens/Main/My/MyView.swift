//
//  MyView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/24/25.
//

import SwiftUI
import Snap

struct MyView: View {
    @State private var isSheetPresented = true
    
    var body: some View {
        GeometryReader { proxy in
            InnerScrollView(screenHeight: proxy.size.height)
        }

    }
}
struct InnerScrollView: View {
    let screenHeight: CGFloat

    // 초기 시트 위치 — 화면 절반 아래에서 시작
    private var initialOffsetY: CGFloat { screenHeight / 2 }

    @State private var selectedTab = 0
    @State private var scrollOffset: CGFloat = 0

    // 0 → 시트 초기 위치, 1 → 시트 상단 도달
    private var sheetProgress: CGFloat {
        min(1, max(0, -scrollOffset / initialOffsetY))
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 보라색 프로필 배경 (ProfileNavigationBar 높이만큼 상단 여백)
            VStack(alignment: .leading, spacing: 0) {
                Color.clear.frame(height: 44)
                ProfileHeaderView()
                    .padding(.top, 20)
                    .padding(.horizontal, 20)
                BioCardView()
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.purpleBlueGradient)
            BottomDragSheet()
//            // 단일 ScrollView:
//            // - 위로 스크롤 → 프로필 영역이 사라지며 시트가 상단까지 올라옴
//            // - 시트 상단 도달 → 탭바 고정, 리스트 이어서 스크롤
//            // - 아래로 스크롤 → 리스트 먼저 내려가다가 최상단 도달 시 시트 내려감
//            ScrollView(.vertical, showsIndicators: false) {
//                VStack(spacing: 0) {
//                    Color.clear.frame(height: initialOffsetY)
//
//                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//                        Section {
//                            sheetListContent
//                        } header: {
//                            sheetTabHeader
//                                .background(Color(.systemBackground))
//                        }
//                    }
//                    .background(
//                        UnevenRoundedRectangle(cornerRadii: .init(
//                            topLeading: 24, bottomLeading: 0,
//                            bottomTrailing: 0, topTrailing: 24
//                        ))
//                        .fill(Color(.systemBackground))
//                    )
//                }
//                .background(
//                    GeometryReader { geo in
//                        Color.clear.preference(
//                            key: ScrollOffsetKey.self,
//                            value: geo.frame(in: .named("scroll")).minY
//                        )
//                    }
//                )
//            }
//            .coordinateSpace(name: "scroll")
//            .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
//
//            // ProfileNavigationBar를 최상단 레이어에 배치:
//            // 리스트 콘텐츠가 스크롤되어도 항상 위에 표시됨
//            ProfileNavigationBar()
//                .background(
//                    // 시트가 올라올수록 흰 배경으로 전환
//                    Color(.systemBackground).opacity(sheetProgress)
//                        .ignoresSafeArea()
//                )
        }
    }

    // MARK: - 시트 탭 헤더 (고정)

    private var sheetTabHeader: some View {
        VStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.vertical, 8)

            HStack(spacing: 0) {
                ForEach(["찜한 공연", "내 후기"], id: \.self) { tab in
                    let idx = tab == "찜한 공연" ? 0 : 1
                    Button(tab) { selectedTab = idx }
                        .font(.subheadline.weight(selectedTab == idx ? .semibold : .regular))
                        .foregroundColor(selectedTab == idx ? .purple : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(alignment: .bottom) {
                            if selectedTab == idx {
                                Rectangle().fill(Color.purple).frame(height: 2)
                            }
                        }
                }
            }
            Divider()
        }
    }

    // MARK: - 시트 리스트 컨텐츠 (스크롤)
    private var sheetListContent: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Text("15건")
                .font(.footnote)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            ForEach(0..<100, id: \.self) { _ in
                PerformanceRowPlaceholder()
                Divider().padding(.leading, 20)
            }
        }
    }
}

// MARK: - Preference Key (스크롤 오프셋 추적용)
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    MyView()
}

struct BioCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("한줄소개")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Text("\"지금 이 순간, 마법처럼.\"")
                .font(.body)
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.15))
        .cornerRadius(16)
    }
}

// MARK: - 시트 내부 콘텐츠
struct SheetTabAndListPlaceholder: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // 탭 선택
            HStack(spacing: 0) {
                ForEach(["찜한 공연", "내 후기"], id: \.self) { tab in
                    let idx = tab == "찜한 공연" ? 0 : 1
                    Button(tab) { selectedTab = idx }
                        .font(.subheadline.weight(selectedTab == idx ? .semibold : .regular))
                        .foregroundColor(selectedTab == idx ? .purple : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .overlay(alignment: .bottom) {
                            if selectedTab == idx {
                                Rectangle()
                                    .fill(Color.purple)
                                    .frame(height: 2)
                            }
                        }
                }
            }
            Divider()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    Text("15건")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    
                    ForEach(0..<100, id: \.self) { _ in
                        PerformanceRowPlaceholder()
                        Divider().padding(.leading, 20)
                    }
                }
            }
        }
    }
}

// MARK: - Placeholder Views

struct ProfileNavigationBar: View {
    var body: some View {
        HStack {
            Button { } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "gearshape")
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct ProfileHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(.white.opacity(0.3))
                .frame(width: 72, height: 72)
                .wrapToButton {
                    print("프로필 클릭!!")
                }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("취향탐구중")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                
                HStack(spacing: 20) {
                    StatView(label: "찜한 공연", value: "102")
                    StatView(label: "작성 후기", value: "43")
                }
            }
        }
    }
}

struct StatView: View {
    let label: String
    let value: String
    var body: some View {
        VStack(spacing: 2) {
            Text(label).font(.caption2).foregroundColor(.white.opacity(0.7))
            Text(value).font(.title3.bold()).foregroundColor(.white)
        }
    }
}

struct PerformanceRowPlaceholder: View {
    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(0.15))
                .frame(width: 64, height: 80)
            VStack(alignment: .leading, spacing: 4) {
                Text("공연 제목 [지역]")
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.caption2)
                    Text("25/03/01~오픈런")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: "mappin")
                        .font(.caption2)
                    Text("공연장명")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

struct BottomDragSheet: View {
    @State private var currentOffset: CGFloat = 0
    @State private var endOffset: CGFloat = 0
    
    let sheetHeight: CGFloat = 120 //바텀 시트 높이 설정
    let sensitivity: CGFloat = 1 //드래그 민감도 (1이 기본, 0.5는 덜 민감, 2는 더 민감)
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let sheetPosition = geometry.size.height - sheetHeight
                VStack {
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 80, height: 4)
                        .padding(.top)
                    
                    ScrollView{
                        SheetTabAndListPlaceholder()
                    } //여기 바텀시트안에 넣고 싶은 뷰 넣기
                }
                .frame(maxWidth: .infinity)
                .background(Color.white.cornerRadius(30))
                .offset(y: sheetPosition + currentOffset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            withAnimation(.spring()) {
                                currentOffset = value.translation.height * sensitivity + endOffset
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                // 큰창
                                if currentOffset <  -sheetPosition / 2 {
                                    currentOffset = -sheetPosition
                                    // 중간 창
                                } else if currentOffset < -100 {
                                    currentOffset = -sheetPosition / 2
                                    // 작은 창
                                } else {
                                    currentOffset = 0
                                }
                                endOffset = currentOffset
                            }
                        }
                )
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        BottomDragSheet()
    }
}


import SwiftUI

// MARK: - ScrollView 오프셋 추적용 PreferenceKey
struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - 특정 모서리에만 cornerRadius 적용
struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        ).cgPath)
    }
}

extension View {
    func roundedCorners(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Hex Color 지원
extension Color {
    init(hex: String) {
        var str = hex.trimmingCharacters(in: .alphanumerics.inverted)
        if str.count == 3 { str = str.map { "\($0)\($0)" }.joined() }
        var val: UInt64 = 0
        Scanner(string: str).scanHexInt64(&val)
        self.init(
            red:   Double((val >> 16) & 0xFF) / 255,
            green: Double((val >> 8)  & 0xFF) / 255,
            blue:  Double(val         & 0xFF) / 255
        )
    }
}

// MARK: - HomeView
// Android: CoordinatorLayout + BottomSheetBehavior (activity_home.xml)
struct HomeView: View {

    // ── Sheet 위치 상태 ──────────────────────────────────────────
    /// 시트 상단의 현재 Y 좌표 (화면 최상단 기준, ignoresSafeArea 포함)
    @State private var sheetY: CGFloat = UIScreen.main.bounds.height * 0.44

    /// 현재 드래그 제스처 시작 시점의 sheetY
    @State private var dragStartY: CGFloat = UIScreen.main.bounds.height * 0.44

    // ── 내부 리스트 스크롤 추적 ──────────────────────────────────
    /// 내부 ScrollView 오프셋 (0 = 맨 위, 음수 = 스크롤 내려간 상태)
    @State private var innerScrollOffset: CGFloat = 0

    // ── Geometry 상수 (onAppear에서 정확한 값으로 갱신) ─────────
    /// 시트 접힌 상태의 Y (화면 중앙 근처 — Android guideline marginTop=193dp 역할)
    @State private var peekY: CGFloat       = UIScreen.main.bounds.height * 0.44
    /// 시트 펼쳐진 상태의 Y (네비게이션 바 바로 아래)
    @State private var expandedY: CGFloat   = 88
    /// 전체 화면 높이 (safeArea 포함)
    @State private var totalScreenH: CGFloat = UIScreen.main.bounds.height
    /// 하단 safeArea inset
    @State private var safeBottomInset: CGFloat = 0

    // ── 계산된 상태 ─────────────────────────────────────────────
    /// 시트가 완전히 펼쳐진 상태 (= 네비게이션 바 바로 아래에 위치)
    private var isExpanded: Bool { sheetY <= expandedY + 2 }

    // MARK: - Body
    var body: some View {
        GeometryReader { geo in
            let safeTop  = geo.safeAreaInsets.top
            let safeBot  = geo.safeAreaInsets.bottom
            let totalH   = geo.size.height + safeTop + safeBot
            let navH     = safeTop + 44                      // 상태바 + 네비게이션바 높이
            // Android guideline marginTop=193dp 에 해당하는 위치
            // 화면 중앙보다 약간 위쪽 — 프로필 영역이 위에 보이도록 배치
            let peek     = safeTop + max(160, geo.size.height * 0.38)

            ZStack(alignment: .top) {
                // ① 배경 / 프로필 영역 (Android: RelativeLayout — cl_menu, tv_moneny 등)
                profileBackground(safeTop: safeTop)

                // ② BottomSheet (Android: RelativeLayout with bottom_sheet_behavior)
                sheetView(
                    totalH:  totalH,
                    screenW: geo.size.width,
                    navH:    navH,
                    peek:    peek,
                    safeBot: safeBot
                )

                // ③ 하단 네비게이션 바 (Android: ll_bottom_btns)
                bottomNavBar(safeBot: safeBot)
            }
            .ignoresSafeArea()
            .onAppear {
                peekY          = peek
                expandedY      = navH
                totalScreenH   = totalH
                safeBottomInset = safeBot
                sheetY         = peek
                dragStartY     = peek
            }
        }
    }

    // MARK: - ① 프로필 배경 영역
    // Android: RelativeLayout (er_bg_main_image, cl_menu, tv_moneny, ll_usetime)
    @ViewBuilder
    func profileBackground(safeTop: CGFloat) -> some View {
        ZStack(alignment: .top) {
            // 메인 그라데이션 배경 (er_bg_main_gradation)
            LinearGradient(
                colors: [Color(hex: "4B72D9"), Color(hex: "7FA2F2")],
                startPoint: .top,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // 네비게이션 행 (cl_menu, tv_version, 알람 아이콘 없음 — 알람은 시트에 있음)
                HStack(alignment: .center, spacing: 6) {
                    // 메뉴 버튼 (cl_menu / er_btn_main_owner)
                    Button(action: { /* 사이드 메뉴 열기 */ }) {
                        ZStack(alignment: .topTrailing) {
                            VStack(spacing: 4) {
                                ForEach(0..<3, id: \.self) { _ in
                                    Capsule().fill(Color.white).frame(width: 22, height: 2)
                                }
                            }
                            .frame(width: 32, height: 32)
                            // 배지 (tv_owner_badge)
                            Circle()
                                .fill(Color.orange)
                                .frame(width: 14, height: 14)
                                .overlay(Text("1").font(.system(size: 8, weight: .bold)).foregroundColor(.white))
                                .offset(x: 4, y: -4)
                        }
                        .frame(width: 44, height: 44)
                    }

                    // 버전 텍스트 (tv_version)
                    Text("v3.1.27")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))

                    Spacer()
                }
                .padding(.leading, 12)
                .padding(.top, safeTop + 4)

                // 프로필 콘텐츠 행
                HStack(alignment: .top) {
                    // 건물 일러스트 (er_bg_main_image)
                    Image(systemName: "building.2.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white.opacity(0.38))
                        .frame(width: 130, height: 105)
                        .padding(.leading, 16)
                        .padding(.top, 8)

                    Spacer()

                    // 이번달 인건비 (tv_moneny)
                    VStack(alignment: .trailing, spacing: 6) {
                        Text("이번달 인건비")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                        Text("₩2,450,000")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 18)
                }
                Spacer()
            }
        }
    }

    // MARK: - ② BottomSheet View
    // Android: RelativeLayout(id=bottom_sheet) — BottomSheetBehavior 동작 재현
    @ViewBuilder
    func sheetView(totalH: CGFloat, screenW: CGFloat, navH: CGFloat, peek: CGFloat, safeBot: CGFloat) -> some View {
        let sheetHeight = max(0, totalH - sheetY)

        VStack(spacing: 0) {

            // ── 드래그 핸들 + 헤더 (항상 드래그 가능) ───────────────────────
            sheetHeader()
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { v in
                            // 요구사항 2, 3: expandedY(최상단) ~ peek(초기위치) 사이로 제한
                            let proposed = dragStartY + v.translation.height
                            sheetY = max(expandedY, min(peek, proposed))
                        }
                        .onEnded { v in
                            snapSheet(
                                translation: v.translation.height,
                                velocity:    v.predictedEndTranslation.height,
                                peek:        peek
                            )
                        }
                )

            Divider()
                .padding(.horizontal, 20)
                .opacity(0.5)

            // ── 내부 리스트 (Android: RecyclerView — mRecyclerView) ──────────
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    // 스크롤 오프셋 앵커 뷰
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetKey.self,
                            value: proxy.frame(in: .named("innerScroll")).minY
                        )
                    }
                    .frame(height: 0)

                    ForEach(0..<25, id: \.self) { i in storeCell(i) }

                    // 하단 네비게이션 바 높이만큼 패딩
                    Color.clear.frame(height: safeBot + 90)
                }
            }
            .coordinateSpace(name: "innerScroll")
            .onPreferenceChange(ScrollOffsetKey.self) { innerScrollOffset = $0 }
            // 요구사항 2: 시트가 완전히 펼쳐진 상태에서만 내부 스크롤 활성화
            .scrollDisabled(!isExpanded)
            // 요구사항 4: 시트 최상단 + 리스트 맨 위 + 아래 드래그 → 시트 접기
            .simultaneousGesture(
                DragGesture(minimumDistance: 10)
                    .onChanged { v in
                        guard isExpanded,
                              innerScrollOffset >= -2,   // 리스트가 맨 위
                              v.translation.height > 0   // 아래 방향 드래그
                        else { return }

                        let proposed = dragStartY + v.translation.height
                        withAnimation(.interactiveSpring(response: 0.28, dampingFraction: 0.9)) {
                            sheetY = max(expandedY, min(peek, proposed))
                        }
                    }
                    .onEnded { v in
                        guard isExpanded,
                              innerScrollOffset >= -2,
                              v.translation.height > 0
                        else {
                            // 조건 불충족 시 dragStartY 동기화만 수행
                            dragStartY = sheetY
                            return
                        }
                        snapSheet(
                            translation: v.translation.height,
                            velocity:    v.predictedEndTranslation.height,
                            peek:        peek
                        )
                    }
            )
        }
        .frame(width: screenW, height: sheetHeight)
        .background(Color(UIColor.systemBackground))
        .roundedCorners(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: -6)
        .offset(y: sheetY)
    }

    // MARK: - 시트 헤더 (드래그 핸들 + 타이틀 + 알람 버튼)
    // Android: 시트 상단 — iv_msg(알람), 핸들 역할의 상단 여백
    @ViewBuilder
    func sheetHeader() -> some View {
        VStack(spacing: 0) {
            // 드래그 핸들 인디케이터
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(UIColor.systemGray4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 8)

            // 제목 + 알람 버튼 행
            HStack(alignment: .center) {
                Text("나의 매장")
                    .font(.system(size: 18, weight: .semibold))

                Spacer()

                // 알람 버튼 (Android: iv_msg / iv_msgnew — 시트 내부에 위치)
                Button(action: { /* 공지사항 열기 */ }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.primary)
                        // 새 알림 배지 (iv_msgnew)
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 10, height: 10)
                            .offset(x: 3, y: -2)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.trailing, 12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
        }
        .contentShape(Rectangle()) // 전체 영역 터치 가능하게 설정
    }

    // MARK: - Snap 헬퍼 (스프링 애니메이션으로 expanded/peek 중 하나로 고정)
    func snapSheet(translation: CGFloat, velocity: CGFloat, peek: CGFloat) {
        withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
            let midY = (expandedY + peek) / 2
            if translation < -50 || velocity < -250 {
                sheetY = expandedY   // 위쪽으로 스냅 (펼침)
            } else if translation > 50 || velocity > 250 {
                sheetY = peek        // 아래쪽으로 스냅 (접힘)
            } else {
                // 중간에서 손을 뗀 경우 → 가까운 쪽으로 스냅
                sheetY = sheetY < midY ? expandedY : peek
            }
        }
        dragStartY = sheetY
    }

    // MARK: - 매장 셀 (Android: RecyclerView 행 — storeListAdapter ViewHolder)
    @ViewBuilder
    func storeCell(_ index: Int) -> some View {
        let icons    = ["cup.and.saucer.fill", "fork.knife", "cart.fill", "bag.fill", "storefront.fill"]
        let workers  = [2, 3, 5, 1, 4]
        let wages    = [120, 98, 156, 210, 74]   // 만원 단위

        VStack(spacing: 0) {
            HStack(spacing: 14) {
                // 매장 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.accentColor.opacity(0.09))
                        .frame(width: 54, height: 54)
                    Image(systemName: icons[index % icons.count])
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                }

                // 매장 정보
                VStack(alignment: .leading, spacing: 5) {
                    Text("매장 \(index + 1)호점")
                        .font(.system(size: 16, weight: .medium))
                    HStack(spacing: 5) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("알바 \(workers[index % workers.count])명  ·  ₩\(wages[index % wages.count])만원")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
            .onTapGesture { print("매장 \(index + 1) 선택됨") }

            // 구분선
            Rectangle()
                .fill(Color(UIColor.separator).opacity(0.4))
                .frame(height: 0.5)
                .padding(.leading, 88)
        }
    }

    // MARK: - ③ 하단 네비게이션 바
    // Android: ll_bottom_btns (ll_store, ll_labor, ll_paystub, ll_info)
    @ViewBuilder
    func bottomNavBar(safeBot: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                navTabItem(icon: "building.2",   label: "매장/직원",  isSelected: true)
                navTabItem(icon: "doc.text",     label: "근로계약서", isSelected: false)
                navTabItem(icon: "banknote",     label: "급여명세서", isSelected: false)
                navTabItem(icon: "info.circle",  label: "안내",       isSelected: false)
            }
            .frame(height: 60)
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle().fill(Color(UIColor.separator).opacity(0.5)).frame(height: 0.5),
                alignment: .top
            )
            .padding(.bottom, safeBot)
        }
    }

    @ViewBuilder
    func navTabItem(icon: String, label: String, isSelected: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: isSelected ? icon + ".fill" : icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .accentColor : Color(UIColor.secondaryLabel))
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(isSelected ? .accentColor : Color(UIColor.secondaryLabel))
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture { print("\(label) 탭 선택") }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomeView()
                .previewDisplayName("iPhone 15 Pro")
            HomeView()
                .previewDevice("iPhone SE (3rd generation)")
                .previewDisplayName("iPhone SE")
        }
    }
}

