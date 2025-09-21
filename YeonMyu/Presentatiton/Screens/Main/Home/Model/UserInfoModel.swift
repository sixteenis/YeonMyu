//
//  UserInfoModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation


struct UserInfoModel {
    let likes: String
    let recodePlayCnt: String
    let schedulePlayCnt: String
}

enum UserInfo {
    case liikes
    case recodePlayCnt
    case schedulePlayCnt
}
