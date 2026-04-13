//
//  UserDefaultManager.swift
//  YeonMyu
//
//  Created by 박성민 on 3/23/25.
//

import Foundation

final class UserDefaultManager {
    static let shared = UserDefaultManager()
    @UserDefault(key: "uid", defaultValue: "", storage: .standard)
    var uid: String
    
    @UserDefault(key: "recentSearch", defaultValue: [String](), storage: .standard)
    var recentSearch: [String]
    
    private init() {}
    
    
}
