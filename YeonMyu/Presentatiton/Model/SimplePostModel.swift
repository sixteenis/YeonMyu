//
//  SimplePostModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct SimplePostModel: Identifiable {
    let id = UUID()
    let postId: String //id
    let postURL: String
    let postType: String //공연 종류
    let postTitle: String
    let startDate: String
    let endDate: String
    var fullDate: String? = nil
    let location: String
}
