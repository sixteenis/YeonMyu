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
    let segments: [String] = ["공연정보", "티켓예매", "위치/시설"]
    
    @Namespace private var name
    @State private var currentPage = 0
    @State private var selectPage = 0
    @State private var position = ScrollPosition(edge: .top)
    @State private var isStopCurrentPage = false
    @State private var allInfo = false
    
    @State private var contentState: ContentState = .loading
    @State private var postInfo = DetailPerformance()
    @State private var placeInfo = PlaceModel()
    var postID: String
    
    
}

extension PlayDetailView {
    var body: some View {
        contentView()
        .navigationTitle(postInfo.name)
        .task {
            do {
                let postData = try await NetworkManager.shared.requestDetailPerformance(performanceId: postID).transformDetailModel()
                let placeData = try await NetworkManager.shared.requestFacility(facilityId: postData.placeId).transformPlaceModel()
                postInfo = postData
                placeInfo = placeData
                contentState = .content
                
            } catch {
                contentState = .error
            }
        }
    }
}
// MARK: - 메인 뷰
private extension PlayDetailView {
    func contentView() -> some View {
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
                    ticketInfoView()
                        .frame(height: 600)
                        .id(5)
                    Rectangle()
                        .frame(height: 12)
                        .id(6)
                    Rectangle()
                        .frame(height: 12)
                        .id(7)
                    placeInfoView()
                        .frame(height: 600)
                        .id(8)
                    Rectangle()
                        .frame(height: 160)
                        .id(9)
                }
            }
            .scrollTargetLayout()
        }
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
                CustomPostImage(url: postInfo.posterURL)
                    .frame(width: screenWidth, height: screenWidth)
                    .blur(radius: 3)
                CustomPostImage(url: postInfo.posterURL)
                    .frame(width: screenWidth / 2.0, height: screenWidth / 1.5)
            } //: ZStack
            Text(postInfo.state.title) // asText 대신 Text로 변경 (asText가 정의되지 않았으므로)
                .font(.boldFont16)
                .foregroundStyle(Color.asWhite)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 30)
                        .fill(postInfo.state.backColor)
                )
            HStack(alignment: .center, spacing: 9) {
                Text(postInfo.genrenm)
                    .font(.boldFont14)
                    .foregroundStyle(Color.asGray300)
                Rectangle()
                    .frame(width: 1, height: 9)
                    .foregroundStyle(Color.asGray400)
                Text(postInfo.limitAge)
                    .font(.boldFont14)
                    .foregroundStyle(Color.asGray300)
            }
            Text(postInfo.name)
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
            customInfo(header: "공연기간", info: postInfo.playDate)
            customInfo(header: "공연장소", info: postInfo.place)
            customInfo(header: "공연시간", info: postInfo.guidance)
            customInfo(header: "러닝타임", info: postInfo.runtime)
            customInfo(header: "관람연령", info: postInfo.limitAge)
            customInfo(header: "출연배우", info: postInfo.actors)
            customInfo(header: "제작진", info: postInfo.teams)
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
    func ticketInfoView() -> some View {
        Text("티켓 정보")
    }
    func placeInfoView() -> some View {
        Text("공연장 정보")
    }
}
//공연 설명 포스터 부분
private extension PlayDetailView {
    func inforPost() -> some View {
        VStack(spacing: 0) {
            // 이미지들을 포함하는 VStack
            VStack(spacing: 0) {
                ForEach(postInfo.DetailPosts, id: \.self) { imageUrl in
                    KFImage(URL(string: imageUrl))
                        .placeholder {
                            Image.postPlaceholder
                                .resizable()
                        }
                        .retry(maxCount: 3, interval: .seconds(5))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity) // 가로 폭을 화면에 맞춤
                        .clipped() // 프레임 밖으로 나가는 부분 잘라내기
                }
            }
            .frame(maxHeight: allInfo ? nil : 300) // allInfo가 true면 높이 제한 없음, false면 300으로 제한
            .clipped() // 높이 제한 시 잘리도록 설정
            
            // 전체보기 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.3)) { // 부드러운 전환을 위한 애니메이션 추가
                    allInfo.toggle()
                }
            } label: {
                Text(allInfo ? "접기" : "전체보기") // 버튼 텍스트 동적 변경
                    .font(.boldFont16)
                    .foregroundColor(.asPurple300)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.asGray100.opacity(0.2))
                    )
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    PlayDetailView(postID: "")
}
