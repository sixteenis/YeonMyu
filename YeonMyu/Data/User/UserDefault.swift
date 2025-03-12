//
//  UserDefault.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/30/24.
//

import Foundation

import Foundation

@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults
    
    var wrappedValue: T {
        get { self.storage.object(forKey: self.key) as? T ?? self.defaultValue}
        set { self.storage.set(newValue, forKey: self.key)}
    }
}
