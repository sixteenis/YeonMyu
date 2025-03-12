//
//  UserManger.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/30/24.
//

import Foundation

final class UserManager {
    static let shared = UserManager()
    
    @UserDefault(key: "userNick", defaultValue: "공연이", storage: .standard)
    var userNick: String
    
    
    
    private init() {}
    
    
}
