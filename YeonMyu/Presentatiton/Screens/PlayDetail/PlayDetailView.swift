//
//  PlayDetailView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/30/25.
//

import SwiftUI
import Kingfisher

enum ScrollType: Int {
    case playInfo
    case ticketInfo
    case placeInfo
}

struct PlayDetailView: View {
    var postID: String
    var exUrl = "http://www.kopis.or.kr/upload/pfmPoster/PF_PF248955_240912_102352.gif"
    var exInfoUrl = ["http://www.kopis.or.kr/upload/pfmIntroImage/PF_PF245617_240723_0146290.jpg"]
    let segments: [String] = ["공연정보", "티켓예매", "위치/시설"]
    var data = DetailPerformance()
    @Namespace private var name
    @State private var currentPage = 0
    @State private var selectPage = 0
    @State private var position = ScrollPosition(edge: .top)
    @State private var isStopCurrentPage = false
    @State private var allInfo = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                postView()
                    .padding(.bottom, 40)
                    .id(-1)
                Color.clear.frame(height: 1).id(0)
                Section(header: stickyHeader()) {
                    playInfo()
                        .id(1)
                    inforPost()
                        .id(2)
                    Rectangle()
                        .frame(height: 1)
                        .id(3)
                    
                    Rectangle()
                        .frame(height: 50)
                    
                    
                    
                    Rectangle()
                        .frame(height: 1)
                        .id(4)
                    ticketInfo()
                        .frame(height: 600)
                        .id(5)
                    Rectangle()
                        .frame(height: 12)
                        .id(6)
                    Rectangle()
                        .frame(height: 12)
                        .id(7)
                    placeInfo()
                        .frame(height: 600)
                        .id(8)
                    Rectangle()
                        .frame(height: 160)
                        .id(9)
                }
            }
            .scrollTargetLayout()
        }
        .navigationTitle("공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명공연명")
        .scrollPosition($position, anchor: .top)
        .onScrollTargetVisibilityChange(idType: Int.self) { id in
            // 사용자가 클릭으로 스크롤 중일 때는 동작하지 않음
            guard !isStopCurrentPage, let firstId = id.first else { return }
            
            print("스크롤 감지로 변경 \(firstId)")
            let newcurrent: Int
            switch firstId {
            case -1,0,1,2,3:
                newcurrent = 0
                selectPage = -1
            case 4,5,6: newcurrent = 1
            case 7,8,9: newcurrent = 2
            default: newcurrent = 0
            }
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
                currentPage = newcurrent
            }
        }
        .onChange(of: selectPage) { oldValue, newValue in
            print("사용자 클릭 감지로 변경 이전 \(oldValue)")
            print("사용자 클릭 감지로 변경 \(newValue)")
            isStopCurrentPage = true
            
            
            withAnimation(.interactiveSpring(response: 0.5, dampingFraction: 0.8, blendDuration: 0.3)) {
                switch newValue {
                case 0:
                    position.scrollTo(id: 0, anchor: .top)
                    currentPage = newValue
                case 1:
                    position.scrollTo(id: 5, anchor: .top)
                    currentPage = newValue
                case 2:
                    position.scrollTo(id: 8, anchor: .top)
                    currentPage = newValue
                default: break
                }
            } completion: {
                print("스크롤 완료!!!")
                isStopCurrentPage = false
            }
        }
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
//                            withAnimation {
                                selectPage = index
//                            }
                            
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
//                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2), value: currentPage)
                    .offset(x: CGFloat(currentPage) * (UIScreen.main.bounds.width / CGFloat(segments.count)))
                    .vBottom()
            }
            .frame(height: 40)
        }
        .background(Color.asWhite)
    }
    //공연정보
    func playInfo() -> some View {
        VStack(alignment: .leading, spacing: 28) {
            asText("공연 정보")
                .font(.font20)
                .foregroundStyle(Color.asFont)
                .padding([.horizontal, .top], 24)
            customInfo(header: "공연기간", info: "임시 텍스트!!!!!!!!!!!")
            customInfo(header: "공연장소", info: "임시 텍스트!!!!!!!!!!!")
            customInfo(header: "공연시간", info: "임시 텍스트!!!!!!!!!!!")
            customInfo(header: "러닝타임", info: "임시 텍스트!!!!!!!!!!!")
            customInfo(header: "관람연령", info: "임시 텍스트!!!!!!!!!!!임시 텍스트!!!!!!!!!!!임시 텍스트!!!!!!!!!!!임시 텍스트!!!!!!!!!!!임시 텍스트!!!!!!!!!!!")
            customInfo(header: "출연배우", info: "임시 텍스트!!!!!!!!!!!")
            customInfo(header: "제작진", info: "임시 텍스트!!!!!!!!!!!")
        }
    }
    func customInfo(header: String, info: String) -> some View {
        HStack(alignment: .top, spacing: 0) {
            asText(header)
                .font(.font16)
                .foregroundStyle(Color.asFont)
                .frame(width: 100, alignment: .leading)
            asText(info)
                .font(.font16)
                .foregroundStyle(Color.asGray100)
                //.multilineTextAlignment(.leading) // 줄바꿈시 정렬이 적용안되는 이슈 해결용!
        }
        .padding(.horizontal, 24)
    }
    func ticketInfo() -> some View {
        Text("티켓 정보")
    }
    func placeInfo() -> some View {
        Text("공연장 정보")
    }
}
//공연 설명 포스터 부분
private extension PlayDetailView {
    func inforPost() -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: allInfo ? 2000 : 300)
            Button {
                // Action
                allInfo.toggle()
            } label: {
                Text("전체보기")
            }
            //ForEach(data.DetailPosts, id: \.self) {
//            ForEach(exInfoUrl, id: \.self) {
//                KFImage(URL(string: $0))
//                    .placeholder { //플레이스 홀더 설정
//                        Image.postPlaceholder
//                            .resizable()
//                    }.retry(maxCount: 3, interval: .seconds(5)) //재시도
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            }
        }
    }

}

#Preview {
    PlayDetailView(postID: "")
}
