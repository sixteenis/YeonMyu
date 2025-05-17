//
//  SearchResultVM.swift
//  YeonMyu
//
//  Created by 박성민 on 5/11/25.
//

import Foundation
import Combine
import RealmSwift
import SwiftUICore

final class SearchResultVM: ViewModeltype {
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output = Output()
    private let realm: Realm
    var coordinator: MainCoordinator?
        
    init() {
        self.cancellables = Set<AnyCancellable>()
        do {
            self.realm = try Realm()
            // 초기 RecentSearch 객체 확인/생성
            ensureRecentSearchObject()
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
        let presentBottomSheet = PassthroughSubject<Int,Never>() //날짜, 지역 클릭시 바텀시트
        let addSearchTerm = PassthroughSubject<String, Never>() //검색어 검색 시
        let deleteSearchTerm = PassthroughSubject<String, Never>() //검색 기록 삭제 시
        let tapTop10Item = PassthroughSubject<String, Never>() // top10 공연 클릭 시
    }
    struct Output {
        var seachText = "" //검색어
        var selectedDate = Date() //검색 날짜
        var selectedCity: CityCode = UserManager.shared.getUserData().getCityCode() //검색 지역
        var seachHistories: [String] = [] //검색 기록
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
                    // Pass the bindings to presentSheet
                    coordinator?.presentSheet(.totalSelect(
                        selected: page,
                        date: dateBinding,
                        city: cityBinding,
                        price: .constant(0...Int.max)
                    ))
                }.store(in: &cancellables)
        
        input.addSearchTerm
            .sink { [weak self] term in
                guard let self else { return }
                self.addSearchTerm(term) //검색어 추가
                coordinator?.push(.searchResult(search: term, date: output.selectedDate, city: output.selectedCity))
            }.store(in: &cancellables)
        
        input.deleteSearchTerm
            .sink { [weak self] term in
                guard let self else { return }
                self.deleteSearchTerm(term) //검색어 삭제
            }.store(in: &cancellables)
        
        input.tapTop10Item
            .sink { [weak self] id in
                guard let self else { return }
                coordinator?.push(.playDetail(id: id))
            }.store(in: &cancellables)
    }
}

private extension SearchResultVM {
    func ensureRecentSearchObject() {
        // 고유 ID로 RecentSearch 객체 확인
        let searchId = "default_search_history"
        if realm.object(ofType: RecentSearch.self, forPrimaryKey: searchId) == nil {
            // RecentSearch 객체가 없으면 생성
            let recentSearch = RecentSearch()
            recentSearch._id = searchId
            try? realm.write {
                realm.add(recentSearch)
            }
        }
        // 초기 검색 기록 로드
        updateSearchHistories()
    }
    func updateSearchHistories() {
        // RecentSearch 객체에서 검색 기록 가져오기
        let searchId = "default_search_history"
        if let recentSearch = realm.object(ofType: RecentSearch.self, forPrimaryKey: searchId) {
            output.seachHistories = Array(recentSearch.seachList)
        }
    }
    func addSearchTerm(_ term: String) {
        guard !term.isEmpty else { return }
        let searchId = "default_search_history"
        guard let recentSearch = realm.object(ofType: RecentSearch.self, forPrimaryKey: searchId) else { return }
        
        try? realm.write {
            // 중복 검색어 제거
            if let existingIndex = recentSearch.seachList.firstIndex(of: term) {
                recentSearch.seachList.remove(at: existingIndex)
            }
            // 새로운 검색어 추가 (앞쪽에)
            recentSearch.seachList.insert(term, at: 0)
            // 최대 10개 제한
            if recentSearch.seachList.count > 10 {
                recentSearch.seachList.removeLast()
            }
        }
        
        // Output 업데이트
        updateSearchHistories()
    }
    
    func deleteSearchTerm(_ term: String) {
        let searchId = "default_search_history"
        guard let recentSearch = realm.object(ofType: RecentSearch.self, forPrimaryKey: searchId) else { return }
        try? realm.write {
            if let existingIndex = recentSearch.seachList.firstIndex(of: term) {
                recentSearch.seachList.remove(at: existingIndex)
            }
        }
        updateSearchHistories()
    }
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

