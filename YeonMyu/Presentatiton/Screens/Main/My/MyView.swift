//
//  MyView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/24/25.
//

import SwiftUI
import Snap

struct MyView: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @Environment(UserUseCase.self) private var userUseCase
    @State private var isSheetPresented = true
    @MainActor private var navHeight = CGFloat.safeAreaTop + 12 + 28 + 12
    let safeAreaTop: CGFloat = 10
    @State private var profileContentHeight: CGFloat = 300
    
    // 초기 시트 위치 — BioCardView 하단까지의 실제 높이
    private var initialOffsetY: CGFloat { profileContentHeight }
    
    @State private var selectedTab = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var stickyOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Image.asGradientColor
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .frame(maxWidth: .infinity)
                    .frame(height: navHeight, alignment: .top)
                
                
                ZStack(alignment: .top) {
                    GeometryReader { geo in
                        // 너비 기준으로 스케일 후 navHeight만큼 위로 올려서 첫 이미지와 이어지게 함
                        Image.asGradientColor
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width)
                            .offset(y: -navHeight)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
                    // 보라색 프로필 배경 (ProfileNavigationBar 높이만큼 상단 여백)
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            profileHeaderView()
                                .padding(.horizontal, 20)
                            bioCardView()
                                .padding(.top, 8)
                                .padding(.horizontal, 20)
                        }
                        .background(
                            GeometryReader { geo in
                                Color.clear
                                    .onAppear { profileContentHeight = geo.size.height + 20 }
                                    .onChange(of: geo.size.height) { _, newValue in
                                        profileContentHeight = newValue + 20
                                    }
                            }
                        )
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear.frame(height: initialOffsetY)
                            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                                Section {
                                    sheetListContent()
                                        .frame(minHeight: UIScreen.main.bounds.height - navHeight + 12, alignment: .top)
                                        .background(Color.asGray600)
                                } header: {
                                    sheetTabHeader()
                                        .background(
                                            GeometryReader { geometry in
                                                Color.clear
                                                    .onChange(of: geometry.frame(in: .global).minY) { _, newValue in
                                                        stickyOffset = newValue
                                                    }
                                            }
                                        )
                                }
                            }
                        } //:VSTACK
                    } //:SCROLL
                    .onAppear { UIScrollView.appearance().bounces = false }
                } //:ZSTACK
            } //:VSTACK
            .ignoresSafeArea(edges: .vertical)
            Button {
                print("설정페이지 이동")
                coordinator.push(.profileSetting)
            } label: {
                Image.asSetting
                    .resizable()
                    .scaledToFill()
                    .frame(width: 28, height: 28)
                    .padding(.trailing, 24)
                    .padding(.top, 16)
                    .foregroundStyle(Color.asWhite)
            }
            .vTop()
            .hTrailing()
        }
    }
}

// MARK: - 프로필 UI
private extension MyView {
    //프로필 정보
    func profileHeaderView() -> some View {
        HStack(spacing: 16) {
            userUseCase.userInfo.getProfileImage()
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .wrapToButton {
                    print("프로필 클릭!!")
                }
            
            VStack(alignment: .leading, spacing: 12) {
                Text(userUseCase.userInfo.name)
                    .font(.boldFont24)
                    .foregroundColor(.asWhite)
                
                HStack(spacing: 0) {
                    statView(label: "찜한 공연", value: userUseCase.userInfo.likesPerformance.count.formatted())
                    statView(label: "작성 후기", value: userUseCase.userInfo.reviews.count.formatted())
                }
            }
        }
    }
    // 한줄 소개
    func bioCardView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Triangle()
                .fill(Color.white.opacity(0.15))
                .frame(width: 20, height: 12)
                .padding(.leading, 50)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("한줄소개")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text(userUseCase.userInfo.introduction)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.15))
            .cornerRadius(16)
        }
    }
    // 정보 표시 공통 UI
    func statView(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            asText(label)
                .font(.font14)
                .foregroundColor(.asPurple500)
            asText(value)
                .font(.boldFont24)
                .foregroundColor(.asWhite)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
// MARK: - 바텀시트 UI
private extension MyView {
    // 시트 탭 헤더 (고정)
    func sheetTabHeader() -> some View {
        ZStack {
            if stickyOffset <= navHeight + 10 {
                
                GeometryReader { geo in
                    // 너비 기준으로 스케일 후 navHeight만큼 위로 올려서 첫 이미지와 이어지게 함
                    Image.asGradientColor
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width)
                        .offset(y: -navHeight)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            }
            
            VStack(spacing: 0) {
                // pinned 시 네비게이션 바 영역(safeAreaTop)만큼 배경이 채워지도록 투명 공간 확보
                //            Color.clear
                //                .frame(height: isPinned ? safeAreaTop : 0)
                //                .animation(.easeInOut(duration: 0.2), value: isPinned)
                HStack(spacing: 0) {
                    ForEach(["찜한 공연", "내 후기"], id: \.self) { tab in
                        let idx = tab == "찜한 공연" ? 0 : 1
                        Button(tab) { selectedTab = idx }
                            .font(.font16)
                            .foregroundColor(selectedTab == idx ? .asPurple300 : .asGray300)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .overlay(alignment: .bottom) {
                                if selectedTab == idx {
                                    Rectangle().fill(Color.asPurple300).frame(width: 70, height: 3)
                                }
                            }
                        //                            .font(.subheadline.weight(selectedTab == idx ? .semibold : .regular))
                    }
                }
                Divider()
                asText("15건")
                    .font(.font16)
                    .foregroundColor(.asGray200)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.asGray600)
            .clipShape(
                UnevenRoundedRectangle(cornerRadii: .init(
                    topLeading: 12, bottomLeading: 0,
                    bottomTrailing: 0, topTrailing: 12
                ))
            )
        }
        
    }
    // 시트 리스트 컨텐츠 (스크롤)
    func sheetListContent() -> some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(0..<5, id: \.self) { _ in
                PerformanceRowPlaceholder()
                    .padding(.horizontal, 24)
            }
        }
    }
}

//삼각형 모형 만들기~
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
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
        .background(Color.asWhite)
    }
}
