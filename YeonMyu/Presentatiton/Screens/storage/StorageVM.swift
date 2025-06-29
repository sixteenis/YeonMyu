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
        let infoTap = PassthroughSubject<StorageType,Never>() //날짜, 지역 클릭시 바텀시트
        
    }
    struct Output {
        var selectedStorageType = StorageType.likes

    }
    func transform() {
        input.infoTap
            .sink { [weak self] type in
                guard let self else { return }
                self.output.selectedStorageType = type
            }.store(in: &cancellables)

    }
}
