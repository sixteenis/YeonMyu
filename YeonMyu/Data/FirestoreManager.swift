//
//  FirestoreManager.swift
//  YeonMyu
//
//  Created by 박성민 on 3/20/25.
//

import Foundation
import FirebaseFirestore

struct UserModel {
    let name: String
    let area: String
}



final class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
}
// MARK: - 유저 관련 코드
extension FirestoreManager {
    //계정 조회
    func fetchUserInfo(uid: String) async throws -> UserModel? {
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        
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
extension FirestoreManager {
    
}
