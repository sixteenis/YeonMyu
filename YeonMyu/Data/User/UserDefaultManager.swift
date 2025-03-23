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
    
    @UserDefault(key: "name", defaultValue: "", storage: .standard)
    var name: String
    
    @UserDefault(key: "area", defaultValue: "", storage: .standard)
    var area: String
    
    private init() {}
    
    
}
