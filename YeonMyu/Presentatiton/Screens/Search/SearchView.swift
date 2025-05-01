//
//  SearchView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 3/3/25.
//

import SwiftUI

struct SearchView: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @StateObject private var vm: SearchVM = SearchVM()
    @FocusState private var isFocused: Bool //키보드 포커싱
    @State private var isAreSelectedPresented = false
    @State private var isDateSelectedPresented = false
    
}
extension SearchView {
    var body: some View {
        content()
            .navigationTitle("검색")
            .sheet(isPresented: $isDateSelectedPresented) {
                DateSelectBottomSheetView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.45)]) //바텀시트 크기
            }
            .sheet(isPresented: $isAreSelectedPresented) {
                CitySelectBottomSheetView(selectedCity: vm.output.selectedCity, compltionCity: $vm.output.selectedCity)
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.45)]) //바텀시트 크기
            }
    }
}

private extension SearchView {
    func content() -> some View {
        ScrollView {
            search()
                .padding(.horizontal, 22)
            
            if !vm.output.seachHistories.isEmpty {
                recentSearches()
                    .hLeading()
                    .padding([.leading,.vertical],24)
            }
            
            playtop10Info()
                .hLeading()
                .padding([.horizontal, .top], 24)
            
        }
        .onChange(of: vm.output.moveSearchResult) { oldValue, newValue in
            if newValue != "" {
                coordinator.push(.searchResult(search: newValue))
                vm.output.moveSearchResult = ""
            }
        }
        .onChange(of: vm.output.moveDetailPlayView) { oldValue, newValue in
            if newValue != "" {
                coordinator.push(.playDetail(id: newValue))
                vm.output.moveDetailPlayView = ""
            }
        }
    }
}

private extension SearchView {
    // 최상단 검색 부분
    func search() -> some View {
        VStack(spacing: 0) {
            HStack {
                Image.search
                    .resizable()
                    .foregroundStyle(Color.asGray300)
                    .frame(width: 24, height: 24)
                TextField("보고 싶은 공연 이름을 검색하세요", text: $vm.output.seachText)
                    .submitLabel(.search)
                    .focused($isFocused)
                    .onSubmit {
                        vm.input.addSearchTerm.send(vm.output.seachText)
                    }
                    .onAppear {
                        isFocused = true
                    }
                
            }
            .padding(14)
            
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color.asGray400)
            
            HStack {
                HStack {
                    Image.calendarIcon
                        .resizable()
                        .foregroundStyle(Color.asGray300)
                        .frame(width: 24, height: 24)
                    asText(vm.output.seachDate)
                        .font(.font14)
                        .foregroundStyle(Color.asGray300)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 14)
                .wrapToButton {
                    isDateSelectedPresented.toggle()
                }
                
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(Color.asGray400)
                
                HStack {
                    Image.markerIcon
                        .resizable()
//                        .foregroundStyle(Color.asGray300)
                        .frame(width: 24, height: 24)
                    asText(vm.output.selectedCity.rawValue)
                        .font(.font14)
                        .foregroundStyle(Color.asGray300)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.trailing, 14)
                .padding(.vertical, 10)
                .wrapToButton {
                    isAreSelectedPresented.toggle()
                }
            }
        }
        .padding(2) // 테두리 두께를 위한 추가 패딩
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.clear)
                .strokeBorder(Color.asPurple300, lineWidth: 1.5) // stroke 대신 strokeBorder 사용
        )
    }
    // 최근 검색어 부분
    func recentSearches() -> some View {
        VStack {
            Text("최근 검색어")
                .font(.font16)
                .foregroundStyle(Color.asGray200)
                .hLeading()
            
            FlowLayout(spacing: 12, lineSpacing: 10) {
                ForEach(vm.output.seachHistories, id: \.self) { text in
                    HStack(spacing: 4) {
                        Text(text)
                            .font(.font14)
                            .foregroundStyle(Color.asGray300)
                            .frame(maxWidth: 80)
                        
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundStyle(Color.asGray300)
                            .wrapToButton {
                                vm.input.deleteSearchTerm.send(text)
                            }
                        
                    }
                    .padding(.horizontal, 8) // 좌우 여백 추가
                    .padding(.vertical, 4)   // 상하 여백 추가
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.clear)
                            .stroke(Color.asGray300, lineWidth: 1)
                    )
                    .wrapToButton {
                        vm.input.addSearchTerm.send(text)
                    }
                }
            }
            .hLeading()
        }
    }
    // 티켓 판매량 뷰 부분
    func playtop10Info() -> some View {
        VStack {
            Text("티켓 판매량 TOP 10")
                .font(.boldFont20)
                .hLeading()
            ForEach(Array(vm.output.top10List.enumerated()), id: \.1.id) { index, item in
                HStack {
                    Text("\(index + 1)")
                        .font(.font16)
                        .foregroundStyle(Color.asGray300)
                        .frame(width: 22, alignment: .center)
                    
                    asText(item.getPostString())
                        .font(.font10)
                        .foregroundStyle(Color.asMainPurple)
                        .padding(.horizontal, 5) // 좌우 여백 추가
                        .padding(.vertical, 2)   // 상하 여백 추가
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.clear)
                                .stroke(Color.asMainPurple, lineWidth: 1)
                        )
                    
                    Text(item.postTitle)
                        .font(.font16)
                        .foregroundStyle(Color.asFont)
                }
                .padding(.bottom, 18)
                .hLeading()
                .wrapToButton {
                    vm.input.tapTop10Item.send(item.postId)
                }
            }
        }
    }
}
#Preview {
    SearchView()
}
