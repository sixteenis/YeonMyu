//
//  ReviewSetVM.swift
//  YeonMyu
//
//  Created by 박성민 on 10/29/25.
//

import Foundation
import Combine

final class ReviewSetVM: ViewModeltype {
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    struct Input {
        
    }
    struct Output {
        var reviewModel = ReviewModel(likeLate: 0, feelingTypes: [], emotionTypes: [], environmentTypes: [], setting: "")
    }
    init() {
        transform()
    }
    func transform() {
        
    }
}

private extension ReviewSetVM {
    
}
