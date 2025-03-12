//
//  DetailPerformanceView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/26/24.
//

import SwiftUI
import MapKit

import Kingfisher

struct DetailPerformanceView: View {
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    @State private var showNextView = false
    @State private var showDetail = false
    @State private var showMap = false
    @State private var placeData = PlaceModel()
    @State private var region = MKCoordinateRegion()
    var data: DetailPerformance = DetailPerformance()
    var selecetDate = ""
    var tab: MainView
    var body: some View {
        ScrollView {
            postView(80)
            Divider()
            Spacer()
                .frame(height: 20)
            postInfo()
            Divider()
            Spacer()
                .frame(height: 20)
            ticketInfo()
            Divider()
            Spacer()
                .frame(height: 20)
            actorInfo()
            Divider()
            inforPost()
        }
        .navigationTitle(data.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action
                    showNextView = true
                } label: {
                    Image.ticketPlus
                        .resizable()
                        .frame(width: 40, height: 40)
                }
                .background(
                    NavigationLink(destination: TicketMakeView(vm: TicketMakeVM(), data: data, date: selecetDate), isActive: $showNextView) {
                        
                        EmptyView() // 실제 링크를 표시하지 않음
                    }
                )
                
            }
        }
        .onAppear {
            tab.tabBarVisibility = .hidden
        }
        .onDisappear {
            // MARK: - 탭바 숨기기 이슈~~~
            if !showNextView {
                tab.tabBarVisibility = .visible
            }
            print("없어짐")
        }
        .task {
            do {
                let result = try await NetworkManager.shared.requestFacility(facilityId: data.placeId)
                self.placeData = result.transformPlaceModel()
                region.center = CLLocationCoordinate2D(latitude: self.placeData.latitude, longitude: self.placeData.longitude)
                region.span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            } catch {
                print("공연장 가져오기 오류 발생")
            }
        }
        
        
        
    }
    
}
private extension DetailPerformanceView {
}
// MARK: - 작품정보 부분
private extension DetailPerformanceView {
    func postInfo() -> some View {
        VStack(alignment: .leading) {
            Text("작품정보")
                .font(.boldFont18)
            performancInfo()
        }
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
    }
    func performancInfo() -> some View {
        HStack() {
            VStack(alignment: .leading) {
                performancInfoText(main: "공연기간", content: data.playDate)
                performancInfoText(main: "공연장소", content: data.place)
            }
            .frame(width: 200)
            Spacer()
                .frame(width: 10)
            Rectangle()
                .frame(width: 1, height: 100)
            Spacer()
                .frame(width: 20)
            VStack(alignment: .leading) {
                performancInfoText(main: "관람 연령", content: data.limitAge)
                performancInfoText(main: "러닝 타임", content: data.runtime)
                Spacer()
            }
            
        } //:HSTACK
        
        
    }
    func performancInfoText(main: String, content: String) -> some View {
        VStack(alignment: .leading) {
            Text(main)
                .asForeground(Color.asGrayFont)
                .font(.font16)
            Spacer()
                .frame(height: 10)
            Text(content)
                .font(.boldFont14)
            Spacer()
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}
// MARK: - 배우, 제작진 뷰 부분
private extension DetailPerformanceView {
    func actorInfo() -> some View {
        VStack(alignment: .leading) {
            Text("배우,제작진 정보")
                .font(.boldFont18)
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
                .frame(height: 10)
            actorsTitle()
        }
        .padding(.horizontal)
    }
    @ViewBuilder
    func actorsTitle() -> some View {
        if showDetail {
            detailActorsInfor()
        } else {
            simpleActorsInfor()
        }
        
    }
    func simpleActorsInfor() -> some View {
        VStack(alignment: .leading) {
            Text("배우")
                .asForeground(Color.asGrayFont)
                .font(.font16)
            Spacer()
                .frame(height: 10)
            HStack {
                Text(data.actors)
                    .lineLimit(1)
                    .font(.boldFont14)
                Spacer()
                Button {
                    // Action
                    showDetail.toggle()
                } label: {
                    Text("더보기")
                        .asForeground(.font)
                        .font(.boldFont14)
                }
            }
            
        }
    }
    func detailActorsInfor() -> some View {
        VStack(alignment: .leading) {
            performancInfoText(main: "배우", content: data.actors)
            Spacer()
                .frame(height: 10)
            performancInfoText(main: "제작진", content: data.teams)
            //            Text("제작사")
            //                .font(.title3)
            //                .bold()
            //            Text("머머머 어쩌구 저쩌구")
            //            Text("기획사")
            //                .font(.title3)
            //                .bold()
            //            Text("머머머 어쩌구 저쩌구")
        }
    }
}
// MARK: - 공연장 뷰 부분
private extension DetailPerformanceView {
    func ticketInfo() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("공연정보")
                .font(.boldFont18)
            
            performancInfoText(main: "공연일정", content: data.guidance)
            performancInfoText(main: "티켓금액", content: data.ticketPrice)
            placeView()
        }
        .padding(.horizontal)
        .frame(width: UIScreen.main.bounds.width, alignment: .leading)
        
    }
    @ViewBuilder
    func placeView() -> some View {
        
        if showMap {
            detailPlace()
        } else {
            simplePlace()
        }
        
    }
    func simplePlace() -> some View {
        VStack(alignment: .leading) {
            Text("공연장 위치")
                .asForeground(Color.asGrayFont)
                .font(.font16)
            Spacer()
                .frame(height: 10)
            HStack {
                Text(placeData.address)
                    .lineLimit(1)
                    .asForeground(Color.asFont)
                    .font(.boldFont14)
                Spacer()
                Button {
                    // Action
                    showMap.toggle()
                } label: {
                    Text("지도보기")
                        .asForeground(.font)
                        .font(.boldFont14)
                }
                
            }
        }
        
    }
    func detailPlace() -> some View {
        VStack(alignment: .leading) {
            Text("공연장 위치")
                .asForeground(Color.asGrayFont)
                .font(.font16)
            Spacer()
                .frame(height: 10)
            Text(self.placeData.address)
                .asForeground(Color.asFont)
                .font(.boldFont14)
            Spacer()
                .frame(height: 10)
            mapView()
        }
        .frame(width: width, alignment: .leading)
    }
    func mapView() -> some View {
        VStack {
            Map(coordinateRegion: self.$region, annotationItems: [Location(coordinates: CLLocationCoordinate2D(latitude: self.placeData.latitude, longitude: self.placeData.longitude))]) { location in
                //MapMarker(coordinate: location.coordinates, tint: .blue)
                MapAnnotation(coordinate: location.coordinates) {
                    CustomMapMarker()
                }
            }
            .frame(width: width - 30, height: 200)
                
        }
        
        
    }
}
// MARK: - 소개 포스트 부분
private extension DetailPerformanceView {
    @MainActor
    func postView(_ size: CGFloat) -> some View {
        VStack {
            KFImage(URL(string: data.posterURL))
                .placeholder { //플레이스 홀더 설정
                    Image.postPlaceholder
                        .resizable()
                }.retry(maxCount: 3, interval: .seconds(5)) //재시도
                .resizable()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: width, height: height))) //이미지 용량이 너무 커서 메모리 용량 많이 잡아먹는 이슈 발생
                .aspectRatio(contentMode: .fill)
                .frame(width: size * 2, height: size * 3)
            Spacer()
                .frame(height: 15)
            Capsule()
                .frame(width: 70, height: 30)
                .asForeground(data.state.backColor)
                .overlay {
                    Text(data.state.title)
                        .font(.boldFont13)
                        .asForeground(Color.white)
                }
            Text(data.name)
                .font(.title2)
                .fontWeight(.semibold)
                .asForeground(.asBlack)
        }
    }
    
    @MainActor func inforPost() -> some View {
        VStack(spacing: 0) {
            ForEach(data.DetailPosts, id: \.self) {
                KFImage(URL(string: $0))
                    .placeholder { //플레이스 홀더 설정
                        Image.postPlaceholder
                            .resizable()
                    }.retry(maxCount: 3, interval: .seconds(5)) //재시도
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
            
        }
        .padding(.horizontal, 10)
    }
    
}
#Preview {
    DetailPerformanceView(tab: MainView())
}




// MARK: - 예정
//private extension DetailPerformanceView {
//    @MainActor func DetailInforImage() -> some View {
//        VStack(spacing: 0) {
//            VStack {
//                KFImage(URL(string: "http://www.kopis.or.kr/upload/pfmIntroImage/PF_PF248302_240903_1144300.jpg"))
//                    .placeholder { //플레이스 홀더 설정
//                        Image.postPlaceholder
//                    }.retry(maxCount: 3, interval: .seconds(5)) //재시도
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                KFImage(URL(string: "http://www.kopis.or.kr/upload/pfmIntroImage/PF_PF248302_240903_1144300.jpg"))
//                    .placeholder { //플레이스 홀더 설정
//                        Image.postPlaceholder
//                    }.retry(maxCount: 3, interval: .seconds(5)) //재시도
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//            }
//            .frame(height: postImageShowDetail ? UIScreen.main.bounds.height  : 200, alignment: .top)
//            .clipped()
//            .padding(.horizontal, 10)
//            Rectangle()
//                .frame(maxWidth: .infinity)
//                .padding(.horizontal, 10)
//                .frame(height: 40)
//                .opacity(0.7)
//                .asForeground(Color.asBackground)
//                .asForeground(.asBackground)
//                .wrapToButton {
//                    self.postImageShowDetail.toggle()
//                }
//                .overlay {
//                    if postImageShowDetail {
//                        Image.upImage
//                    } else {
//                        Image.downImage
//                    }
//                }
//        }
//
//    }
//}
