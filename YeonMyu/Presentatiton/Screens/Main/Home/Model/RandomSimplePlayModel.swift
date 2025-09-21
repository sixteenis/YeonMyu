//
//  RandomSimplePlayModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 3/3/25.
//

import Foundation


struct RandomSimplePlayModel: Identifiable {
    let id = UUID().uuidString
    let mainTitle: String
    let subTitle: String
    let simplePlayData: [SimplePostModel]
}
