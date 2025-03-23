//
//  FirestoreManager.swift
//  YeonMyu
//
//  Created by 박성민 on 3/20/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

enum SignState: String, Identifiable {
    case none
    case signIn
    case newJoin
    case signOut
    case error
    var id: String { self.rawValue}
}
struct UserModel {
    let name: String
    let area: String
}

final class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    
    private init() {}
    func checkSignInState() async -> SignState {
        if UserDefaultManager.shared.uid.isEmpty { return .none }
        do {
            let result = try await self.fetchUserInfo(uid: UserDefaultManager.shared.uid)
            guard let result else { return .newJoin }
            UserDefaultManager.shared.name = result.name
            UserDefaultManager.shared.area = result.area
            
            return .signIn
        } catch {
            return .error
        }
        
    }
    func checkSignInState(uid: String) async -> SignState {
        do {
            let result = try await self.fetchUserInfo(uid: uid)
            guard let result else { return .newJoin }
            UserDefaultManager.shared.uid = uid
            UserDefaultManager.shared.name = result.name
            UserDefaultManager.shared.area = result.area
            
            return .signIn
        } catch {
            return .newJoin
        }
        
    }
}
// MARK: - 유저 관련 코드
extension UserManager {
    //계정 조회
    func fetchUserInfo(uid: String) async throws -> UserModel? {
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        UserDefaultManager.shared.uid = uid
        guard let data = document.data() else { return nil}
        
        return UserModel(
            name: data["name"] as? String ?? "알수없음",
            area: data["area"] as? String ?? "알수없음"
        )
    }
    //계정 생성
    func createUser(uid: String, name: String, area: String) async throws -> UserModel? {
        let userRef = db.collection("users").document(uid)
        let data: [String: Any] = [
            "name": name,
            "area": area,
            "createdAt": Timestamp()
        ]
        try await userRef.setData(data)
        let result = try await self.fetchUserInfo(uid: uid)
        return result
    }
}
// MARK: - 게시글 관련 코드
//extension FirestoreManager {
//    
//}
