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
        
        transform()
        Task {
            let posts = try await self.fetchSearchPosts(term: searchText, date: selectedDate, cityCode: selectedCity)
            await MainActor.run {
                self.output.searchPosts = self.removeDuplicatePosts(posts)
            }
        }
        bindOutputChanges()
    }
    struct Input {
        let presentBottomSheet = PassthroughSubject<Int,Never>() //날짜, 지역, 금액 클릭시 바텀시트
        let selectPlayCurrentPage = PassthroughSubject<Int, Never>()
        let tapPost = PassthroughSubject<String, Never>() //포스터 클릭 시
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
        
        input.tapPost
            .sink { [weak self] id in
                guard let self else { return }
                coordinator?.push(.playDetail(id: id))
            }.store(in: &cancellables)
    }
    private func bindOutputChanges() {
        Publishers.CombineLatest4(
                    $output.map(\.seachText).removeDuplicates(),
                    $output.map(\.selectedDate).removeDuplicates(),
                    $output.map(\.selectedCity).removeDuplicates(),
                    $output.map(\.selectedPrice).removeDuplicates()
                )
                .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
                .dropFirst(1)
                .sink { [weak self] (searchText, selectedDate, selectedCity, selectedPrice) in
                    guard let self else { return }
                    do {
                        Task {
                            let posts = try await self.fetchSearchPosts(term: searchText, date: selectedDate, cityCode: selectedCity)
                            await MainActor.run {
                                self.output.searchPosts = self.removeDuplicatePosts(posts)
                            }
                        }
                    }
                }.store(in: &cancellables)
    }
}

private extension SearchResultVM {
    
}
// MARK: - 네트워크 부분
private extension SearchResultVM {
    func fetchSearchPosts(term: String, date: Date, cityCode: CityCode) async throws -> [SimplePostModel] {
        if date.checkSelect() { return try await fetchSearchResult(term: term, date: date, cityCode: cityCode)}
        return try await fetchAllDaySearchResult(term: term, cityCode: cityCode)
    }
    //검색 결과 공연정보
    func fetchSearchResult(term: String, date: Date, cityCode: CityCode) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        try await withThrowingTaskGroup(of: [SimplePostModel].self) { group in
            for cate in PrfCate.all.code {
                group.addTask {
                    let result = try await NetworkManager.shared.requestPerformance(
                        date: date.asTrasnFormyyyyMMdd(),
                        cateCode: cate,
                        area: cityCode.code,
                        title: term,
                        page: nil,
                        openrun: nil,
                        prfstate: nil,
                        maxOnePage: "100"
                    )
                    return result.map { $0.transformSimplePostModel() }
                }
            }
            
            for try await result in group {
                data.append(contentsOf: result)
            }
        }
        
        return data
    }
    //검색 결과 날짜 미선택 시
    func fetchAllDaySearchResult(term: String, cityCode: CityCode) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        let min = -150
        let max = 60

        try await withThrowingTaskGroup(of: [SimplePostModel].self) { outerGroup in
            for cate in PrfCate.all.code {
                outerGroup.addTask {
                    var localData: [SimplePostModel] = []

                    try await withThrowingTaskGroup(of: [SimplePostModel].self) { innerGroup in
                        for i in stride(from: min, to: max, by: 30) {
                            innerGroup.addTask {
                                let result = try await NetworkManager.shared.requestPerformance(
                                    stdate: String.getDateRelativeToToday(daysOffset: i),
                                    eddate: String.getDateRelativeToToday(daysOffset: i + 30),
                                    cateCode: cate,
                                    area: cityCode.code,
                                    title: term,
                                    page: nil,
                                    openrun: nil,
                                    prfstate: nil,
                                    maxOnePage: "30"
                                )
                                print("[\(cate)] \(String.getDateRelativeToToday(daysOffset: i)) ~ \(String.getDateRelativeToToday(daysOffset: i + 30))")
                                return result.map { $0.transformSimplePostModel() }
                            }
                        }

                        for try await result in innerGroup {
                            localData.append(contentsOf: result)
                        }
                    }

                    return localData
                }
            }

            for try await result in outerGroup {
                data.append(contentsOf: result)
            }
        }

        return data
    }
    //중복 포스터 제거
    func removeDuplicatePosts(_ posts: [SimplePostModel]) -> [SimplePostModel] {
        return Array(Dictionary(grouping: posts, by: { $0.postURL }).compactMap { $0.value.first })
    }
}

//group.addTask {
//    let result = try await NetworkManager.shared.requestPerformance(
//        stdate: String.getDateRelativeToToday(daysOffset: i),
//        eddate: String.getDateRelativeToToday(daysOffset: i + 30),
//        cateCode: PrfCate.play.code.first!,
//        area: cityCode.code,
//        title: term,
//        page: nil,
//        openrun: nil,
//        prfstate: nil,
//        maxOnePage: "1"
//    )
//    print(i, i + 30)
//    print("-----\(PrfCate.play.code.first!)-----")
//    return result.map { $0.transformSimplePostModel() }
//}
