//
//  UserModel.swift
//  YeonMyu
//
//  Created by 박성민 on 4/6/26.
//

import SwiftUI
// MARK: - 유저 모델
struct UserModel {
    let uid: String
    var name: String
    var introduction: String // 소개글
    var area: String
    var profileID: Int
    var likesPerformance: [LikesPerformanceModel]
    var reviews: [ReviewModel]
    
    func getCityCode() -> CityCode {
        if let cityCode = CityCode.allCases.first(where: { $0.rawValue == area }) {
            return cityCode
        }
        return .seoul
    }
    func getProfileImage() -> Image {
        return Image("profile\(profileID)")
    }
}
