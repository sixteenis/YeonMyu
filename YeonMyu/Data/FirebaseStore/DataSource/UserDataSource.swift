//
//  UserDataSource.swift
//  YeonMyu
//
//  users 컬렉션에만 접근하는 DataSource

import Foundation
import FirebaseFirestore

final class UserDataSource {
    private lazy var db = Firestore.firestore()
}

// MARK: - 유저
extension UserDataSource {
    //유저정보 조회
    func fetchUser(uid: String) async throws -> UserModel? {
        let document = try await db.collection("users").document(uid).getDocument()
        guard let data = document.data() else { return nil }

        let likes = (data["likesPerformance"] as? [[String: Any]] ?? []).map {
            LikesPerformanceModel(
                mt20id: $0["mt20id"] as? String ?? "",
                postType: $0["postType"] as? String ?? "",
                postURL: $0["postURL"] as? String ?? "",
                postTitle: $0["postTitle"] as? String ?? "",
                startDate: $0["startDate"] as? String ?? "",
                endDate: $0["endDate"] as? String ?? "",
                location: $0["location"] as? String ?? ""
            )
        }

        let reviews = (data["reviews"] as? [[String: Any]] ?? []).map { item in
            ReviewModel(
                reviewid: item["reviewid"] as? String ?? "",
                mt20id: item["mt20id"] as? String ?? "",
                postTitle: item["postTitle"] as? String ?? "",
                genreType: Genre.transform(str: item["postType"] as? String ?? "") ,
                rating: item["rating"] as? Int ?? 0,
                selectedPerformanceHighlights: item["selectedPerformanceHighlights"] as? [String] ?? [],
                selectedPerformanceFeelings: item["selectedPerformanceFeelings"] as? [String] ?? [],
                selectedPerformanceEnvironments: item["selectedPerformanceEnvironments"] as? [String] ?? [],
                setting: item["setting"] as? String ?? "",
                review: item["review"] as? String ?? "",
                createdAt: (item["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                userID: item["userID"] as? String ?? "",
                userName: item["userName"] as? String ?? "",
                userProfileID: item["userProfileID"] as? Int ?? 0,
                
            )
        }

        return UserModel(
            uid: uid,
            name: data["name"] as? String ?? "알수없음",
            introduction: data["introduction"] as? String ?? "",
            area: data["area"] as? String ?? "알수없음",
            profileID: data["profileID"] as? Int ?? 0,
            likesPerformance: likes,
            reviews: reviews
        )
    }
    //유저 생성
    func createUser(uid: String, name: String, area: String) async throws {
        let data: [String: Any] = [
            "name": name,
            "area": area,
            "createdAt": Timestamp(),
            "profileID": 0,
            "introduction" : "",
            "likesPerformance": [],
            "reviews": []
        ]
        try await db.collection("users").document(uid).setData(data)
    }
    // 유저 정보 수정
    func updateUser(uid: String, name: String, introduction: String, area: String, profileID: Int) async throws {
        let data: [String: Any] = [
            "name": name,
            "introduction": introduction,
            "area": area,
            "profileID": profileID
        ]
        try await db.collection("users").document(uid).updateData(data)
    }
}


// MARK: - 후기
extension UserDataSource {
    func addReview(uid: String, review: ReviewModel) async throws {
        try await db.collection("users").document(uid).updateData([
            "reviews": FieldValue.arrayUnion([review.toDictionary()])
        ])
    }

    func removeReview(uid: String, reviewid: String) async throws {
        let userRef = db.collection("users").document(uid)
        let document = try await userRef.getDocument()
        guard let data = document.data() else { return }

        let updated = (data["reviews"] as? [[String: Any]] ?? [])
            .filter { $0["reviewid"] as? String != reviewid }

        try await userRef.updateData(["reviews": updated])
    }
}

// MARK: - 찜하기
extension UserDataSource {
    func updateLike(uid: String, like: LikesPerformanceModel, isLike: Bool) async throws {
        let userRef = db.collection("users").document(uid)
        if isLike {
            try await userRef.updateData([
                "likesPerformance": FieldValue.arrayUnion([like.toDictionary()])
            ])
        } else {
            let document = try await userRef.getDocument()
            guard let data = document.data() else { return }
            let updated = (data["likesPerformance"] as? [[String: Any]] ?? [])
                .filter { $0["mt20id"] as? String != like.mt20id }
            try await userRef.updateData(["likesPerformance": updated])
        }
    }
}
