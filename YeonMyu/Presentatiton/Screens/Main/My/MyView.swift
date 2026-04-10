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

            // 단일 ScrollView:
            // - 위로 스크롤 → 프로필 영역이 사라지며 시트가 상단까지 올라옴
            // - 시트 상단 도달 → 탭바 고정, 리스트 이어서 스크롤
            // - 아래로 스크롤 → 리스트 먼저 내려가다가 최상단 도달 시 시트 내려감
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: initialOffsetY)

                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Section {
                            sheetListContent
                        } header: {
                            sheetTabHeader
                                .background(Color(.systemBackground))
                        }
                    }
                    .background(
                        UnevenRoundedRectangle(cornerRadii: .init(
                            topLeading: 24, bottomLeading: 0,
                            bottomTrailing: 0, topTrailing: 24
                        ))
                        .fill(Color(.systemBackground))
                    )
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: ScrollOffsetKey.self,
                            value: geo.frame(in: .named("scroll")).minY
                        )
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }

            // ProfileNavigationBar를 최상단 레이어에 배치:
            // 리스트 콘텐츠가 스크롤되어도 항상 위에 표시됨
            ProfileNavigationBar()
                .background(
                    // 시트가 올라올수록 흰 배경으로 전환
                    Color(.systemBackground).opacity(sheetProgress)
                        .ignoresSafeArea()
                )
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
