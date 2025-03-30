//
//  PlayDetailView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/30/25.
//

import SwiftUI

enum ScrollType: Int {
    case playInfo
    case ticketInfo
    case placeInfo
}

struct PlayDetailView: View {
    var postID: String
    var exUrl = "http://www.kopis.or.kr/upload/pfmPoster/PF_PF248955_240912_102352.gif"
    let segments: [String] = ["공연정보", "티켓예매", "위치/시설"]
    let model = DetailPerformance()
    @Namespace private var name
    @State private var currentPage = 0
    @State private var selectPage = 0
    @State private var position = ScrollPosition(edge: .top) // idType을 Int.self로 수정
    @State private var isStopCurrentPage = false
    
    var body: some View {
        //NavigationStack {
            ScrollView {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    postView()
                        .padding(.bottom, 40)
                    Section(header: stickyHeader()) {
                        playInfo()
                            .frame(height: 600)
                            .id(0) // Int 타입 ID
                        
                        ticketInfo()
                            .frame(height: 600)
                            .id(1) // Int 타입 ID
                        
                        placeInfo()
                            .frame(height: 900)
                            .id(2) // Int 타입 ID
                    }
                    
                } //: LazyVStack
                .scrollTargetLayout()
            } //: ScrollView
            .navigationTitle("공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명")
            .scrollPosition($position, anchor: .top)
            .onScrollTargetVisibilityChange(idType: Int.self) { id in
                guard let firstId = id.first, !isStopCurrentPage else { return }
                print("스크롤 감지로 변경 \(firstId)")
                currentPage = firstId
                selectPage = 4 //의미없는 값으로 사용자 탭 값 변경해주기
            }
            .onChange(of: selectPage) { oldValue, newValue in
                print("사용자 클릭 감지로 변경 \(newValue)")
                if selectPage == 4 { return } //의미없는 값일경우 로직 동작 X
                self.isStopCurrentPage = true
                withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
                    position.scrollTo(id: newValue)
                    currentPage = selectPage
                } completion: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print("완료!!!")
                        self.isStopCurrentPage = false
                    }
                }
            }
            
      //  } //: NavigationStack
    }
}

// MARK: - 맨 상단 포스터 부분
private extension PlayDetailView {
    func postView() -> some View {
        VStack(spacing: 9) {
            ZStack {
                CustomPostImage(url: exUrl)
                    .frame(width: screenWidth, height: screenWidth)
                    .blur(radius: 3)
                CustomPostImage(url: exUrl)
                    .frame(width: screenWidth / 2.0, height: screenWidth / 1.5)
            } //: ZStack
            Text("뮤지컬") // asText 대신 Text로 변경 (asText가 정의되지 않았으므로)
                .font(.boldFont16)
                .foregroundStyle(Color.asWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.asMainPurple)
                )
            HStack(alignment: .center, spacing: 9) {
                Text("뮤지컬")
                    .font(.boldFont14)
                    .foregroundStyle(Color.asGray300)
                Rectangle()
                    .frame(width: 1, height: 9)
                    .foregroundStyle(Color.asGray400)
                Text("전체관람가")
                    .font(.boldFont14)
                    .foregroundStyle(Color.asGray300)
            }
            Text("공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명")
                .font(.font20)
                .foregroundStyle(Color.font)
                .lineLimit(2)
                .padding(.horizontal, 24)
        } //: VStack
    }
}

// MARK: - Sticky Header 및 섹션 뷰
private extension PlayDetailView {
    func stickyHeader() -> some View {
        VStack {
            ZStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(segments.indices, id: \.self) { index in
                        Button {
                            withAnimation {
                                selectPage = index
                                currentPage = index
                            }
                            
                        } label: {
                            ZStack {
                                Text(segments[index])
                                    .font(.boldFont16)
                                    .foregroundColor(currentPage == index ? Color.asPurple300 : Color.asGray300)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(Color.asBorderGrayLine)
                                    .vBottom()
                            }
                                
                        }
                    }
                }
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width / CGFloat(segments.count), height: 4)
                    .foregroundStyle(Color.asPurple300)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2), value: currentPage)
                    .offset(x: CGFloat(currentPage) * (UIScreen.main.bounds.width / CGFloat(segments.count)))
                    .vBottom()
            }
            .frame(height: 40)
        }
        .background(Color.asWhite)
    }
    func playInfo() -> some View {
        VStack(spacing: 14) {
            asText("공연 정보")
                .font(.font20)
                .foregroundStyle(Color.asFont)
        }
    }
    
    func customInfo(header: String, info: String) -> some View {
        HStack(alignment: .top, spacing: 46) {
            asText(header)
                .font(.font16)
                .foregroundStyle(Color.asFont)
            asText(info)
                .font(.font16)
                .foregroundStyle(Color.asGray100)
                .multilineTextAlignment(.leading) // 줄바꿈시 정렬이 적용안되는 이슈 해결용!
        }
    }
    
    
    
    func ticketInfo() -> some View {
        Text("티켓 정보")
    }
    func placeInfo() -> some View {
        Text("공연장 정보")
    }
}

#Preview {
    PlayDetailView(postID: "")
}
