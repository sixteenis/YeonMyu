//
//  StorageVM.swift
//  YeonMyu
//
//  Created by 박성민 on 6/22/25.
//

import Foundation
import Combine
import RealmSwift
import SwiftUICore
enum StorageType {
    case likes
    case watched
    case scheduled
}
final class StorageVM: ViewModeltype {
    var cancellables: Set<AnyCancellable>
    var input = Input()
    @Published var output = Output()
    private let realm: Realm
    var coordinator: MainCoordinator?
        
    init(selected: StorageType) {
        self.cancellables = Set<AnyCancellable>()
        do {
            self.realm = try Realm()
            Task {
    
                let mockData = try await getUserAreaPlayList(area: .all, PrfCate: .all, page: nil)
                await MainActor.run {
                    self.output.scrollPostData = mockData
                }
            }
        } catch {
            fatalError("Failed to initialize Realm: \(error)")
        }
        transform()
    }
    struct Input {
        let infoTap = PassthroughSubject<StorageType,Never>() //보관함 종류 선택 시
        let postTapped = PassthroughSubject<String,Never>() // 포스트 클릭 시
        
    }
    struct Output {
        var selectedStorageType = StorageType.likes
        var scrollPostData: [SimplePostModel] = []

    }
    func transform() {
        input.infoTap
            .sink { [weak self] type in
                guard let self else { return }
                self.output.selectedStorageType = type
                self.output.scrollPostData = self.getPostData(type: type)
            }.store(in: &cancellables)
        
        input.postTapped
            .sink { [weak self] postId in
                guard let self else { return }
                self.coordinator?.push(.playDetail(id: postId))
            }.store(in: &cancellables)
        
    }
    //검색 결과 공연정보
    func getUserAreaPlayList(area: CityCode, PrfCate: PrfCate, page: Int?) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        for cate in PrfCate.code {
            let result = try await NetworkManager.shared.requestPerformance(date: String.getDateRelativeToToday(daysOffset: 0), cateCode: cate, area: area.code, title: "", page: page, openrun: nil, prfstate: nil)
            data.append(contentsOf: result.map{$0.transformSimplePostModel()})
        }
        data.shuffle()
        return data.filter { $0.getPostString() != "" }
    }
}

private extension StorageVM {
    func getPostData(type: StorageType) -> [SimplePostModel] {
        switch type {
        case .likes:
            return getLikeData()
        case .watched:
            return getWatchedData()
        case .scheduled:
            return getScheduledData()
        }
    }
    func getLikeData() -> [SimplePostModel] {
        return []
    }
    func getWatchedData() -> [SimplePostModel] {
        return []
    }
    func getScheduledData() -> [SimplePostModel] {
        return []
    }
    
}
