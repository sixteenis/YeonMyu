//
//  MainView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/12/24.
//

import SwiftUI
import Kingfisher
import Combine

// TODO: 연극이나 뮤지컬 클릭 시 스크롤 탑으로 해주기!
struct MainView: View {
    @State private var isCalendarVisible: Bool = true
    @State var tabBarVisibility: Visibility = .visible
    @StateObject private var vm = MainVM()
    private let width = UIScreen.main.bounds.width
    var body: some View {
        NavigationWrapper {
            VStack(spacing: 10) {
                //cellList()
                ScrollView {
                    LazyVStack(spacing: 0) {
                        calendarViewWithGeometry()
                        Spacer()
                            .frame(height: 15)
                        ForEach(vm.output.showDatas, id: \.id) { data in
                            cell(for: data, width: width, height: 700)
                                .id(data.id)
                                .onTapGesture {
                                    withAnimation {
                                        vm.input.selectCell.send(data.id)
                                    }
                                }
                                .onAppear {
                                    vm.input.showLastItem.send(data)
                                    
                                }
                        }
                    }  //:VSTACK
                }  //:SCROLL
            } //:VSTACK
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if isCalendarVisible {
                        SelectListView(selected: $vm.output.showType)
                            .onChange(of: vm.output.showType) { newType in
                                vm.input.showTypeSet.send(newType)
                            }
                    } else {
                        EmptyView()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if isCalendarVisible {
                            vm.input.searchTypeTap.send(!vm.output.searchType)
                        }
                    } label: {
                        
                        if vm.output.searchType {
                            Image.calendarImage
                                .foregroundColor(.asBlack)
                                .opacity(isCalendarVisible ? 1 : 0)
                        } else {
                            Image.search
                                .foregroundColor(.asBlack)
                                .opacity(isCalendarVisible ? 1 : 0)
                        }
                        
                    }
                    
                    
                }
                ToolbarItem(placement: .principal) {
                    // 캘린더가 보이지 않으면 네비게이션에 표시
                    if !isCalendarVisible {
                        if vm.output.searchType {
                            Text(vm.output.searchText)
                        } else {
                            Text(setDateString(date: vm.output.setDate))
                        }
                    }
                }
            }
        } //:NAVIGATION
        .task {
            vm.input.viewOnTask.send(())
        }
        
        
    }
}

#Preview {
    MainView()
}

private extension MainView {
    func setDateString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    //캘린더 스크롤 로직
    func calendarViewWithGeometry() -> some View {
        GeometryReader { geo in
            HorizontalCalendarView(selectedDate: $vm.output.setDate, showSearch: $vm.output.searchType, searchText: $vm.output.searchText)
                .onSubmit {
                    vm.input.searchTextTap.send(vm.output.searchText)
                }
                .onChange(of: vm.output.setDate) { newDate in
                    vm.input.dateSet.send(newDate)
                }
                .onChange(of: geo.frame(in: .global).minY) { date in
                    // 새로운 구문으로 변경 - 두 개의 매개변수가 없음
                    let newValue = geo.frame(in: .global).minY
                    if newValue < 0 {
                        withAnimation {
                            isCalendarVisible = false // 캘린더가 화면에서 사라짐
                        }
                    } else {
                        withAnimation {
                            isCalendarVisible = true // 캘린더가 화면에 보임
                        }
                    }
                }
        }
        .frame(height: 100) // CalendarView 높이를 고정 (적절한 높이로 설정)
    }
    func cell(for data: PerformanceModel, width: CGFloat, height: CGFloat) -> some View {
        HStack {
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: height * 0.024)
                Circle()
                    .frame(width: 15)
                    .foregroundColor(vm.output.selectCellId == data.id ? Color.asMainColor : Color.asBackground) // 내부 색상
                    .overlay(
                        Circle()
                            .stroke(Color.asMainColor, lineWidth: 2) // 테두리 색상
                    )
                
                
                // MARK: - 마지막 셀에 선을 안주는게 이쁠까??????? 고민해보고 수정 바람
                if let lastData = vm.output.showDatas.last, lastData.id != data.id {
                    Spacer()
                        .frame(height: 6)
                    Rectangle()
                        .fill(Color.asMainColor)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer()
                }
            }
            if vm.output.selectCellId == data.id {
                detailView(data: data, height: height * 0.45)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .padding([.bottom,.top], 10)
                
                
            } else {
                defaultView(data: data.simple, height: height * 0.25)
                    .transition(AnyTransition.scale.animation(.bouncy))
                    .padding([.bottom,.top], 5)
            }
            
            
        }
        //        .frame(height: vm.output.selectCellId == data.id ? height * 0.45 : height * 0.25)
        .padding(.horizontal, 10)
        //.padding(.bottom, 5)
        .animation(.easeInOut, value: vm.output.selectCellId) // 애니메이션 추가
    }
    // MARK: - 미선택한 뷰
    func defaultView(data: SimplePerformance, height: CGFloat) -> some View {
        HStack {
            VStack(spacing: 0) {
                Text(data.playDate)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(.asSubFont)
                    .foregroundColor(Color.asSubFont)
                    .padding([.bottom,.top], 10)
                Text(data.title)
                    .bold()
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(.asMainFont)
                Spacer()
                    .frame(height: 10)
                Text(data.place)
                    .frame(maxWidth: .infinity,alignment: .leading)
                    .font(.asSubFont)
                Spacer()
            }
            .padding(.leading)
            VStack {
                KFImage(URL(string: data.postURL))
                    .placeholder { //플레이스 홀더 설정
                        Image.postPlaceholder
                            .resizable()
                    }.retry(maxCount: 3, interval: .seconds(5)) //재시도
                    .resizable()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: height * 1.0, height: height * 1.7))) //이미지 용량이 너무 커서 메모리 용량 많이 잡아먹는 이슈 발생
                    .onSuccess { result in
                                if let url = result.source.url {
                                    print("Image URL: \(url.absoluteString)")

                                    // URL에 따라 형식 확인 후 용량 출력
                                    if url.pathExtension.lowercased() == "png" {
                                        if let pngData = result.image.pngData() {
                                            let dataSizeInKB = Int(Double(pngData.count) / 1024.0)
                                            print("PNG 이미지 용량: \(dataSizeInKB) KB")
                                        }
                                    } else if url.pathExtension.lowercased() == "jpg" || url.pathExtension.lowercased() == "jpeg" {
                                        if let jpegData = result.image.jpegData(compressionQuality: 1.0) {
                                            let dataSizeInKB = Int(Double(jpegData.count) / 1024.0)
                                            print("JPG 이미지 용량: \(dataSizeInKB) KB")
                                        }
                                    }
                                    print("-------------")
                                }
                            }
                
                    .frame(width: height * 0.3 * 2,height: height * 0.3 * 3, alignment: .top)
                    .padding(.top, 30)
                    .padding(.trailing)
                
                Spacer()
            }
        }
        .frame(height: height)
        .background(Color.asBackground)
        
    }
    // MARK: - 선택한 뷰에 텍스트
    func performancInfoText(main: String, content: String) -> some View {
        VStack(alignment: .leading) {
            Text(main)
                .asForeground(Color.asBoardInFont)
                .font(.font15)
            Spacer()
                .frame(height: 5)
            Text(content)
                .font(.font14)
            Spacer()
                .frame(height: 15)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 선택한 경우 뷰
    func detailView(data: PerformanceModel, height: CGFloat) -> some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.asMainColor)
            VStack(spacing: 0) {
                HStack {
                    VStack {
                        Text(data.simple.playDate)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .font(.asSubFont)
                            .foregroundColor(Color.asBoardInFont)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                        Text(data.simple.title)
                            .bold()
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .font(.asMainFont)
                        Spacer()
                            .frame(height: 10)
                        Text(data.simple.place)
                            .frame(maxWidth: .infinity,alignment: .leading)
                            .font(.asSubFont)
                        Spacer()
                            .frame(height: 30)
                        performancInfoText(main: "관람연령", content: data.detail.limitAge)
                        performancInfoText(main: "런타임", content: data.detail.runtime)
                        performancInfoText(main: "배우", content: data.detail.actors)
                        
                        
                        Spacer()
                    }
                    .padding(.leading)
                    VStack(spacing: 0) {
                        detailButton()
                            .padding(.top, 20)
                        Spacer()
                            .frame(height: height * 0.1)
                        KFImage(URL(string: data.simple.postURL))
                            .placeholder { //플레이스 홀더 설정
                                Image.postPlaceholder
                                    .resizable()
                            }.retry(maxCount: 3, interval: .seconds(5)) //재시도
                            .resizable()
                            .frame(width: height * 0.22 * 2,height: height * 0.22 * 3, alignment: .top)
                            .background(Color.blue)
                            .padding(.trailing)
                        Spacer()
                        //Spacer()
                    } //:VSTACK
                    
                } //:HSTACK
                
                Spacer()
            } //:VSTACK
        }
        .frame(height: height)
        
    }
    func actorProfileView() -> some View {
        HStack {
            Text("출연진: 김부연, 임정균")
                .font(.callout)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading)
    }
    func detailButton() -> some View {
        NavigationLink(destination: DetailPerformanceView(data: vm.output.selectPost,selecetDate: vm.output.selectDate, tab: self)) {
            Text("자세히 보기 >")
                .font(.asMainFont)
                .foregroundColor(.asBoardInFont)
            
        }
        .toolbar(tabBarVisibility, for: .tabBar)
        
        
    }
}

//struct DetailButton: View {
//    var body: some View {
//        Button(action: {
//            // 여기에 디테일 뷰로 push하는 로직을 추가합니다.
//        }) {
//            HStack {
//                Text("자세히 보기")
//                    .foregroundColor(Color.purple)
//                Image(systemName: "chevron.right")
//                    .foregroundColor(Color.purple)
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity)
//            .background(Color.white)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.purple, lineWidth: 1)
//            )
//            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
//        }
//        .padding(.horizontal, 20)
//        .padding(.bottom, 20)
//    }
//}
//
