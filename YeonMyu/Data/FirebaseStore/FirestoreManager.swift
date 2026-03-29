//
//  FirestoreManager.swift
//  YeonMyu
//
//  Created by 박성민 on 3/20/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI
// 로그인 상태
enum SignState: String, Identifiable {
    case none
    case signIn
    case newJoin
    case signOut
    case error
    var id: String { self.rawValue}
}

//찜하기
struct LikesPerformanceModel {
    let mt20id: String // 공연 고유 ID
    let postType: String // 공연 종류
}
//공연 후기
struct ReviewModel {
    let mt20id: String // 공연 고유 ID
    let postType: String // 공연 종류
    let rating: Int //평점
    let selectedPerformanceHighlights: [String]
    let selectedPerformanceFeelings: [String]
    let selectedPerformanceEnvironments: [String]
    let setting: String //좌석
    let review: String // 후기
    let createdAt: Date // 생성일
    
    func toDictionary() -> [String: Any] {
        return [
            "mt20id": mt20id,
            "postType": postType,
            "rating": rating,
            "selectedPerformanceHighlights": selectedPerformanceHighlights,
            "selectedPerformanceFeelings": selectedPerformanceFeelings,
            "selectedPerformanceEnvironments": selectedPerformanceEnvironments,
            "setting": setting,
            "review": review,
            "createdAt": Timestamp()
        ]
    }
}

struct UserModel {
    let uid: String
    let name: String
    let area: String
    let profileID: Int
    let likesPerformance: [LikesPerformanceModel]
    let reviews: [ReviewModel]
    
    func getCityCode() -> CityCode {
        if let cityCode = CityCode.allCases.first(where: { $0.rawValue == area }) {
            return cityCode
        }
        return .seoul
    }
}

final class UserManager {
    static let shared = UserManager()
    private let db = Firestore.firestore()
    private var userInfo = UserModel(uid: "", name: "", area: "", profileID: 0, likesPerformance: [], reviews: [])
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
        let user = UserModel(uid: uid,
                             name: data["name"] as? String ?? "알수없음",
                             area: data["area"] as? String ?? "알수없음",
                             profileID: data["profileID"] as? Int ?? 0,
                             likesPerformance: data["likesPerformance"] as? [LikesPerformanceModel] ?? [],
                             reviews: data["reviews"] as? [ReviewModel] ?? [])
        
        userInfo = user
        return user
    }
    //계정 생성
    func createUser(uid: String, name: String, area: String) async throws -> UserModel? {
        let userRef = db.collection("users").document(uid)
        let data: [String: Any] = [
            "name": name, //닉네임
            "area": area, // 지역
            "createdAt": Timestamp(), //생성일
            "profileID": 0, //프로필 사진 고유 ID
            "likesPerformance": [], //좋아요한 공연 목록
            "reviews": [] // 작성한 후기
        ]
        try await userRef.setData(data)
        let result = try await self.fetchUserInfo(uid: uid)
        
        if let result {
            userInfo = result
        }
        
        return result
    }
    func saveUserData(_ user: UserModel) {
        UserDefaultManager.shared.uid = user.uid
        UserDefaultManager.shared.name = user.name
        UserDefaultManager.shared.area = user.area
        
        userInfo = user
        // TODO: firebase 저장 필요
    }
    
    func getUserData() -> UserModel {
        return userInfo
    }
}
// MARK: - 유저별 찜, 후기 관련 코드
extension UserManager {
    func writeReview(_ review: ReviewModel) async throws {
        try await writheReviewToUserInfo(review)
        try await writheReviewToPerformance(review)
    }
    // 유저 db에 후기 등록
    private func writheReviewToUserInfo(_ review: ReviewModel) async throws {
        let userRef = db.collection("users").document(userInfo.uid)
        let reviewData = review.toDictionary()
        
        try await userRef.updateData([
            "reviews": FieldValue.arrayUnion([reviewData])
        ])
        
        // 로컬 업데이트 (옵션)
        var currentUser = userInfo
        currentUser = UserModel(
            uid: currentUser.uid,
            name: currentUser.name,
            area: currentUser.area,
            profileID: currentUser.profileID,
            likesPerformance: currentUser.likesPerformance,
            reviews: currentUser.reviews + [review]
        )
        
        userInfo = currentUser
    }
    
    // 공연별 db에 후기 등록
    private func writheReviewToPerformance(_ review: ReviewModel) async throws {
        let performanceRef = db.collection("performanceReview").document(review.mt20id)
        let reviewData = review.toDictionary()
        
        try await performanceRef.setData([
            "reviews": FieldValue.arrayUnion([reviewData])
        ], merge: true)
    }
    
    // 유저 db에 찜하기 저장 및 삭제
    func updateLike(_ data: LikesPerformanceModel, isLike: Bool) async throws {
        
        let userRef = db.collection("users").document(userInfo.uid)
        
        let likeData: [String: Any] = [
            "mt20id": data.mt20id,
            "postType": data.postType
        ]
        
        if isLike {
            // 좋아요 추가
            try await userRef.updateData([
                "likesPerformance": FieldValue.arrayUnion([likeData])
            ])
            
            // 로컬 업데이트
            userInfo = UserModel(
                uid: userInfo.uid,
                name: userInfo.name,
                area: userInfo.area,
                profileID: userInfo.profileID,
                likesPerformance: userInfo.likesPerformance + [data],
                reviews: userInfo.reviews
            )
            
        } else {
            // 좋아요 취소
            try await userRef.updateData([
                "likesPerformance": FieldValue.arrayRemove([likeData])
            ])
            
            // 로컬 업데이트
            userInfo = UserModel(
                uid: userInfo.uid,
                name: userInfo.name,
                area: userInfo.area,
                profileID: userInfo.profileID,
                likesPerformance: userInfo.likesPerformance.filter {
                    !($0.mt20id == data.mt20id && $0.postType == data.postType)
                },
                reviews: userInfo.reviews
            )
        }
    }
}
// MARK: - 게시글 관련 코드
//extension FirestoreManager {
//
//}
