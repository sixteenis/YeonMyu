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
                        .foregroundStyle(Color.asGray400)
                        .frame(height: 1)
                        .id(3)
                    
                    Rectangle()
                        .foregroundStyle(Color.asGray400)
                        .frame(height: 11)
                        .id(4)
                    ticketInfoView()
                        .id(5)
                    Rectangle()
                        .foregroundStyle(Color.asGray400)
                        .frame(height: 6)
                        .id(6)
                    
                    Rectangle()
                        .foregroundStyle(Color.asGray400)
                        .frame(height: 6)
                        .id(7)
                    placeInfoView()
                        .id(8)
                    Rectangle()
                        .overlay {
                            VStack {
                                Image.logoS
                                    .resizable()
                                    .foregroundStyle(Color.asGray300)
                                    .frame(width: 108, height: 22)
                                    .padding(.bottom, 12)
                                
                                Text("공연정보 출처")
                                    .font(.font12)
                                    .foregroundStyle(Color.asGray300)
                                Link(destination: URL(string: "https://www.kopis.or.kr")!) {
                                    Text("(재)예술경영지원센터 공연예술통합전산망")
                                        .font(.font12)
                                        .foregroundStyle(Color.asGray300)
                                }
                                    
                            }
                        }
                        .foregroundStyle(Color.asGray400)
                        .frame(height: 160)
                        .id(9)
                }
            }
            .scrollTargetLayout()
        }
        .ignoresSafeArea(edges: .bottom)
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
                    position.scrollTo(id: 4, anchor: .top)
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
                .font(.boldFont20)
                .foregroundStyle(Color.asFont)
                .padding([.horizontal, .top], 24)
            customInfo(header: "공연기간", info: postInfo.playDate)
            customInfo(header: "공연장소", info: postInfo.place)
            customInfo(header: "공연시간", info: postInfo.guidanceList.joined(separator: "\n\n"))
            customInfo(header: "러닝타임", info: postInfo.runtime)
            customInfo(header: "관람연령", info: postInfo.limitAge)
            customInfo(header: "출연배우", info: postInfo.actors)
            customInfo(header: "제작진", info: postInfo.teams)
                .padding(.bottom, 30)
        }
        .hLeading()
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
}
// MARK: - 공연 설명 포스터 부분
private extension PlayDetailView {
    func inforPost() -> some View {
        VStack(spacing: 0) {
            if allInfo {
                // 전체보기 상태: 모든 이미지 보여줌
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
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // 전체보기 이전: 첫 번째 이미지의 앞부분 300만 보여줌
                if let firstImageUrl = postInfo.DetailPosts.first {
                    KFImage(URL(string: firstImageUrl))
                        .placeholder {
                            Image.postPlaceholder
                                .resizable()
                        }
                        .retry(maxCount: 3, interval: .seconds(5))
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .vTop()
                        .frame(height: 300) // 앞부분만 잘라서 보여주기
                        .frame(maxWidth: .infinity)
                        .clipped()
                }
            }
            
            // 전체보기 버튼
            Button {
                withAnimation(.easeInOut(duration: 0.3)) {
                    allInfo.toggle()
                }
            } label: {
                Text(allInfo ? "접기" : "전체보기")
                    .font(.boldFont16)
                    .foregroundColor(.asGray200)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.asWhite)
            }
            .frame(height: 56)
        }
    }
}
// MARK: - 티켓 부분
private extension PlayDetailView {
    func ticketInfoView() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            asText("티켓 정보")
                .font(.boldFont20)
                .foregroundStyle(Color.asFont)
                .padding([.horizontal, .top], 24)
                .padding(.bottom, 20)
            
            customTicketInfo(header: "티켓금액", info: postInfo.ticketPriceList)
                .padding(.bottom, 40)
            
            HStack(alignment: .top, spacing: 0) {
                asText("판매처")
                    .font(.font16)
                    .foregroundStyle(Color.asFont)
                    .frame(width: 100, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(postInfo.relates) {
                        TicketPageView(ticketImage: "", ticketName: $0.relatename, goticketPageURL: $0.relateurl)
                    }
                }
                
            }.padding(.horizontal, 24).padding(.bottom, 40)
            
            
        }.hLeading()
    }
    func customTicketInfo(header: String, info: [String]) -> some View {
        HStack(alignment: .top, spacing: 0) {
            asText(header)
                .font(.font16)
                .foregroundStyle(Color.asFont)
                .frame(width: 100, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) { // 각 항목을 수직으로 배치
                ForEach(info, id: \.self) {
                    let components = splitTextBeforeNumber($0)
                    HStack(alignment: .top, spacing: 0) {
                        asText(components.beforeNumber)
                            .font(.boldFont16) // 숫자 이전 텍스트의 폰트 사이즈
                            .foregroundStyle(Color.asPurple300) // 숫자 이전 텍스트의 색상
                        asText(components.afterNumber)
                            .font(.font16) // 숫자 이후 텍스트의 폰트 사이즈 (기존 스타일 유지)
                            .foregroundStyle(Color.asGray100) // 숫자 이후 텍스트의 색상
                    }
                }
            }
        }
        .padding(.horizontal, 24)
    }
    // 숫자가 나오기 이전과 이후를 분리하는 헬퍼 함수
    func splitTextBeforeNumber(_ text: String) -> (beforeNumber: String, afterNumber: String) {
        // 정규식을 사용하여 숫자가 시작되는 위치를 찾음
        let regex = try? NSRegularExpression(pattern: "\\d")
        let range = regex?.rangeOfFirstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let numberStartIndex = range?.lowerBound, numberStartIndex != NSNotFound {
            let beforeNumber = String(text[..<text.index(text.startIndex, offsetBy: numberStartIndex)])
            let afterNumber = String(text[text.index(text.startIndex, offsetBy: numberStartIndex)...])
            return (beforeNumber, afterNumber)
        } else {
            // 숫자가 없는 경우 전체를 beforeNumber로 처리
            return (text, "")
        }
    }
}
// MARK: - 공연 시설 부분
private extension PlayDetailView {
    // TODO: 진행중
    func placeInfoView() -> some View {
        VStack(alignment: .leading, spacing: 28) {
            asText("위치/시설")
                .font(.boldFont20)
                .foregroundStyle(Color.asFont)
                .padding([.horizontal, .top], 24)
            customInfo(header: "공연장", info: placeInfo.facilityName)
            customInfo(header: "주소", info: placeInfo.address)
            customInfo(header: "지도 보기", info: postInfo.playDate)
            customInfo(header: "공연장 수", info: postInfo.playDate)
            customInfo(header: "객석 수", info: postInfo.playDate)
            customInfo(header: "주요시설", info: postInfo.playDate)
            customInfo(header: "장애시설", info: postInfo.playDate)
                .padding(.bottom, 30)
        }.hLeading()
    }
}

#Preview {
    PlayDetailView(postID: "")
}
