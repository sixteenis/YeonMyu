//
//  SearchVM.swift
//  YeonMyu
//
//  Created by 박성민 on 4/20/25.
//

import Foundation
import Combine
import RealmSwift
import SwiftUICore

final class SearchVM: ViewModeltype {
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
                let top10 = try await self.getTop10List()
                
                await MainActor.run {
                    self.output.top10List = top10
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
        let tapSearchTerm = PassthroughSubject<String, Never>()
        let deleteSearchTerm = PassthroughSubject<String, Never>() //검색 기록 삭제 시
        let tapTop10Item = PassthroughSubject<String, Never>() // top10 공연 클릭 시
    }
    struct Output {
        var seachText = "" //검색어
        var selectedDate = Date.noSelect() //검색 날짜
        var selectedCity: CityCode = .all
        var seachHistories: [String] = [] //검색 기록
        var top10List: [SimplePostModel] = [] //top10 공연 정보
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
                    coordinator?.presentSheet(.dateAndPriceSelect(
                        selected: page,
                        date: dateBinding,
                        city: cityBinding
                    ))
                }.store(in: &cancellables)
        
        input.addSearchTerm
            .sink { [weak self] term in
                guard let self else { return }
                self.addSearchTerm(term) //검색어 추가
                coordinator?.push(.searchResult(search: term, date: output.selectedDate, city: output.selectedCity))
            }.store(in: &cancellables)
        
        input.tapSearchTerm
            .sink { [weak self] term in
                guard let self else { return }
                self.addSearchTerm(term) //검색어 추가
                coordinator?.push(.searchResult(search: term, date: Date.noSelect(), city: .all))
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

private extension SearchVM {
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
    //실시간 top10
    func getTop10List() async throws -> [SimplePostModel] {
        let date = String.getDateRelativeToToday(daysOffset: -30)
        let ddate = String.getDateRelativeToToday(daysOffset: 0)
        
        let data = try await NetworkManager.shared.requestBoxOffice(startDate: date, endDate: ddate, cateCode: "", area: nil)
        
        let result = data.map { $0.transformSimplePostModel()}
        
        return Array(result.filter{ $0.isPlayCheck() }.prefix(10))
    }
}
