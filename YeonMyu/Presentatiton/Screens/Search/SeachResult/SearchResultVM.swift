//
//  SearchResultVM.swift
//  YeonMyu
//
//  Created by 박성민 on 5/11/25.
//

import Foundation
import Combine
import SwiftUICore

final class SearchResultVM: ViewModeltype {
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output: Output
    var coordinator: MainCoordinator?
    
    init(searchText: String, selectedDate: Date, selectedCity: CityCode) {
        self.cancellables = Set<AnyCancellable>()
        self.output = Output(
            seachText: searchText,
            selectedDate: selectedDate,
            selectedCity: selectedCity
        )
        do {
            Task {
                //                let top10 = try await self.getTop10List()
                
                await MainActor.run {
                    //                    self.output.top10List = top10
                }
            }
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
        transform()
    }
    struct Input {
        let presentBottomSheet = PassthroughSubject<Int,Never>() //날짜, 지역, 금액 클릭시 바텀시트
        let selectPlayCurrentPage = PassthroughSubject<Int, Never>()
    }
    struct Output {
        var seachText: String
        var selectedDate: Date
        var selectedCity: CityCode
        var selectedPrice: ClosedRange<Int> = 0...Int.max
        
        var playCategorys = PrfCate.allCases
        var playCurrentPage = 0
        var searchPosts: [SimplePostModel] = [] // 공연 검색 정보
    }
    func transform() {
        input.presentBottomSheet
            .sink { [weak self] page in
                guard let self else { return }
                // Create Binding for selectedDate and selectedCity
                let dateBinding = Binding<Date>(
                    get: { self.output.selectedDate },
                    set: { self.output.selectedDate = $0 }
                )
                let cityBinding = Binding<CityCode>(
                    get: { self.output.selectedCity },
                    set: { self.output.selectedCity = $0 }
                )
                let priceBinding = Binding<ClosedRange<Int>>(
                    get: { self.output.selectedPrice },
                    set: { self.output.selectedPrice = $0 }
                )
                // Pass the bindings to presentSheet
                coordinator?.presentSheet(.totalSelect(
                    selected: page,
                    date: dateBinding,
                    city: cityBinding,
                    price: priceBinding
                ))
            }.store(in: &cancellables)
        
        input.selectPlayCurrentPage
            .sink { [weak self] index in
                guard let self else { return }
                self.output.playCurrentPage = index
            }.store(in: &cancellables)
    }
}

private extension SearchResultVM {
    
}
// MARK: - 네트워크 부분
private extension SearchVM {
    //검색 결과 공연정보
    func fetchSearchResult(term: String, date: String, cityCode: String, price: ClosedRange<Int>) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        for cate in PrfCate.all.code {
            let result = try await NetworkManager.shared.requestPerformance(date: date, cateCode: cate, area: cityCode, title: term, page: nil, openrun: nil, prfstate: nil, maxOnePage: "100")
            data.append(contentsOf: result.map{$0.transformSimplePostModel()})
        }
        return data
    }
}

