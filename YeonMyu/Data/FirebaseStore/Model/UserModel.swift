//
//  UserModel.swift
//  YeonMyu
//
//  Created by 박성민 on 4/6/26.
//

import Foundation

// MARK: - 유저 모델
struct UserModel {
    let uid: String
    let name: String
    let area: String
    let profileID: Int
    let likesPerformance: [LikesPerformanceModel]
    let reviews: [ReviewModel]
    
    func getCityCode() -> CityCode {
        if let cityCode = CityCode.allCases.first(where: { $0.rawValue == area }) {
            return cityCode
        }
        return .seoul
    }
}
