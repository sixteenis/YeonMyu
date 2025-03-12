//
//  MainHeaderPlayModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct MainHeaderPlayModel: Identifiable {
    var id: String = UUID().uuidString
    let mainTitle: String
    let subTitle: String
    let postURL: String
    let postID: String
}
