//
//  SearchResultVM.swift
//  YeonMyu
//
//  Created by 박성민 on 5/11/25.
//

import Foundation
import Combine
import SwiftUICore
enum SearchSortEnum: CaseIterable {
    case nomal
    case date
    case endFiest
    case endLate
    var title: String {
        switch self {
        case .nomal:
            "인기순"
        case .date:
            "최신 개봉순"
        case .endFiest:
            "마감일 빠른순"
        case .endLate:
            "마감일 늦은순"
        }
    }
}
final class SearchResultVM: ViewModeltype {
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output: Output
    var coordinator: MainCoordinator?
    var allSearchPosts: [SimplePostModel] = []
    
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
                self.allSearchPosts = self.removeDuplicatePosts(posts)
                self.output.searchPosts = filterPostData(allData: self.allSearchPosts, playType: self.output.playCategorys[self.output.playCurrentPage], sortType: self.output.searchSortEnum)
            }
        }
        bindOutputChanges()
    }
    
    struct Input {
        let presentBottomSheet = PassthroughSubject<Int,Never>() //날짜, 지역, 금액 클릭시 바텀시트
        let selectPlayCurrentPage = PassthroughSubject<Int, Never>()
        let tapPost = PassthroughSubject<String, Never>() //포스터 클릭 시
        let searchTypeTap = PassthroughSubject<SearchSortEnum, Never>()
    }
    struct Output {
        var seachText: String //검색어
        var selectedDate: Date //날짜
        var selectedCity: CityCode //지역
        var selectedPrice: ClosedRange<Int> = 0...Int.max //가격
        
        var playCategorys = PrfCate.allCases //공연 종류들
        var playCurrentPage = 0 //선택한 공연 index
        var searchSortEnum = SearchSortEnum.nomal //정렬 방식
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
        
        input.searchTypeTap
            .sink { [weak self] type in
                guard let self else { return }
                self.output.searchSortEnum = type
            }.store(in: &cancellables)
        
    }
    private func bindOutputChanges() {
        //검색어, 날짜, 지역, 가격 변경 시 동작
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
                        self.allSearchPosts = self.removeDuplicatePosts(posts)
                        self.output.searchPosts = self.filterPostData(allData: self.allSearchPosts, playType: self.output.playCategorys[self.output.playCurrentPage], sortType: self.output.searchSortEnum)
                    }
                }
            }
        }.store(in: &cancellables)
        
        // TODO: 정렬기준에 금액은 이쪽으로 빼기, 바텀시트에서 날짜 선택안했는데도 자동으로 오늘날짜로 되는 이슈 해결하기
        //검색 공연 종류, 정렬방식 변경 시 동작
        Publishers.CombineLatest(
            $output.map(\.playCurrentPage).removeDuplicates(),
            $output.map(\.searchSortEnum).removeDuplicates()
        )
        .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
        .dropFirst(1)
        .sink { [weak self] (index, sort) in
            guard let self else { return }
            self.output.searchPosts = self.filterPostData(allData: self.allSearchPosts, playType: self.output.playCategorys[self.output.playCurrentPage], sortType: self.output.searchSortEnum)
        }.store(in: &cancellables)
        
    }
}

private extension SearchResultVM {
    func filterPostData(allData: [SimplePostModel], playType: PrfCate, sortType: SearchSortEnum) -> [SimplePostModel] {
        //공연 종류
        var sort = allData //정렬 기준 맞춰주기
        if PrfCate.allCases[self.output.playCurrentPage] != .all {
            sort = sort.filter {$0.postType == playType.title }
        }
        //정렬 순서
        switch sortType {
        case .nomal:
            return sort
        case .date:
            return sort.sorted { $0.startDate > $1.startDate }
        case .endFiest:
            return sort.sorted { $0.endDate > $1.endDate }
        case .endLate:
            return sort.sorted { $0.endDate < $1.endDate }
        }
    }
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
                                    maxOnePage: "15"
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
