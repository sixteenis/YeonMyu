//
//  ReviewModel.swift
//  YeonMyu
//
//  Created by 박성민 on 9/26/25.
//

import Foundation

struct ReviewModel: Identifiable {
    let id = UUID()
    let playID: String
    let playInfo: SimplePostModel
    let likeLate: Int
    
}
