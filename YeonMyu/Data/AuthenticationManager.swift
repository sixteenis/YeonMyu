//
//  AuthenticationManager.swift
//  YeonMyu
//
//  Created by 박성민 on 3/17/25.
//

import Foundation
import FirebaseAuth

//struct AuthUserDataModel {
//    let uid: String
//    let
//}


final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private init() { }
    
    func createUser(email: String, password: String) async throws {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
    }
    
}
