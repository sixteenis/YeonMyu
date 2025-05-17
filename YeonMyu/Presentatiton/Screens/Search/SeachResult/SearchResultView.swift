//
//  SearchResultView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/21/25.
//


import SwiftUI

struct SearchResultView: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @StateObject private var vm: SearchResultVM
    
    init(searchText: String, date: Date, city: CityCode) {
        _vm = StateObject(wrappedValue: SearchResultVM(searchText: searchText, selectedDate: date, selectedCity: city))
    }
    
}

extension SearchResultView {
    var body: some View {
        content()
            .onAppear {
                vm.coordinator = coordinator
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    searchView()
                }
            }
    }
}
private extension SearchResultView {
    func content() -> some View {
        VStack {
            CustomSegmentedView(segments: vm.output.playCategorys.map { $0.title},
                                currentPage: Binding<Int>(
                                    get: { vm.output.playCurrentPage},
                                    set: { vm.input.selectPlayCurrentPage.send($0)}
                                )
            )
            optionsView()
        }
    }
}
private extension SearchResultView {
    func searchView() -> some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(Color.asGray500)
            .frame(width: 265,height: 40) // 외부 프레임 재지정
            .overlay(
                HStack(spacing: 0) {
                    TextField("검색어를 입력해주세요", text: $vm.output.seachText)
                        .font(.font14)
                        .foregroundStyle(Color.asGray300)
                        .padding(.horizontal)
                        .frame(width: 207, alignment: .leading)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Image.search
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.asGray300)
                        .padding(.leading, 14)
                        .padding(.trailing, 10)
                        .hTrailing()
                    
                }
            )
        
    }
    //검색 설정 옵션 뷰
    func optionsView() -> some View {
        HStack {
            optionView(vm.output.selectedDate.checkSelect() ? vm.output.selectedDate.asTrasnFormyy_mm_dd() : "날짜", isCheck: vm.output.selectedDate.checkSelect())
                .wrapToButton {
                    vm.input.presentBottomSheet.send(0)
                }
            optionView(vm.output.selectedCity != .all ? vm.output.selectedCity.rawValue : "지역", isCheck: vm.output.selectedCity != .all)
                .wrapToButton {
                    vm.input.presentBottomSheet.send(1)
                }
            
            if TicketPriceEnum.getType(vm.output.selectedPrice) != nil{
                optionView(TicketPriceEnum.getType(vm.output.selectedPrice)! != .all ? TicketPriceEnum.getType(vm.output.selectedPrice)!.rawValue : "가격", isCheck: TicketPriceEnum.getType(vm.output.selectedPrice)! != .all)
                    .wrapToButton {
                        vm.input.presentBottomSheet.send(2)
                    }
            } else {
                optionView("\(vm.output.selectedPrice.lowerBound / 10_000)만원~\(vm.output.selectedPrice.upperBound / 10_000)만원", isCheck: true)
                    .wrapToButton {
                        vm.input.presentBottomSheet.send(2)
                    }
            }
            
        }
    }
    func optionView(_ title: String, isCheck: Bool) -> some View {
        HStack(spacing: 0) {
            asText(title)
            Image.downArrow
                .resizable()
                .frame(width: 18, height: 18)
                .foregroundStyle(isCheck ? Color.asBlack : Color.asGray300)
                .padding(.leading, 2)
                .padding(.trailing, 4)
        }
        .frame(height: 25)
        .font(.font16)
        .foregroundStyle(isCheck ? Color.asBlack : Color.asGray300)
        .padding(.leading, 10)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.clear)
                .stroke(isCheck ? Color.asBlack : Color.asGray300, lineWidth: 1.5)
        )
    }
}
