//
//  UserUseCase.swift
//  YeonMyu
//
//  UserDataSource · PerformanceDataSource를 조율하고
//  userInfo 상태를 @Observable로 관리하는 UseCase

import Foundation
import Observation

@Observable
final class UserUseCase {
    private let userDS = UserDataSource()
    private let performanceDS = PerformanceDataSource()

    var userInfo = UserModel(uid: "", name: "", introduction: "", area: "", profileID: 0, likesPerformance: [], reviews: [])

    init() {}
}

// MARK: - 인증 상태 확인
extension UserUseCase {
    func checkSignInState() async -> SignState {
        if UserDefaultManager.shared.uid.isEmpty { return .none }
        do {
            let result = try await fetchUserInfo(uid: UserDefaultManager.shared.uid)
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
            let result = try await fetchUserInfo(uid: uid)
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

// MARK: - 유저 CRUD
extension UserUseCase {
    func fetchUserInfo(uid: String) async throws -> UserModel? {
        UserDefaultManager.shared.uid = uid
        let user = try await userDS.fetchUser(uid: uid)
        if let user { userInfo = user }
        return user
    }

    func createUser(uid: String, name: String, area: String) async throws -> UserModel? {
        try await userDS.createUser(uid: uid, name: name, area: area)
        let result = try await fetchUserInfo(uid: uid)
        if let result { userInfo = result }
        return result
    }

    func saveUserData(_ user: UserModel) {
        UserDefaultManager.shared.uid = user.uid
        UserDefaultManager.shared.name = user.name
        UserDefaultManager.shared.area = user.area
        userInfo = user
    }

    func getUserData() -> UserModel {
        return userInfo
    }
}

// MARK: - 후기
extension UserUseCase {
    func writeReview(_ review: ReviewModel) async throws {
        try await userDS.addReview(uid: userInfo.uid, review: review)
        try await performanceDS.addReview(review)
        userInfo = UserModel(
            uid: userInfo.uid,
            name: userInfo.name,
            introduction: userInfo.introduction,
            area: userInfo.area,
            profileID: userInfo.profileID,
            likesPerformance: userInfo.likesPerformance,
            reviews: userInfo.reviews + [review]
        )
    }

    func deleteReview(_ review: ReviewModel) async throws {
        try await userDS.removeReview(uid: userInfo.uid, reviewid: review.reviewid)
        try await performanceDS.removeReview(mt20id: review.mt20id, reviewid: review.reviewid)
        userInfo = UserModel(
            uid: userInfo.uid,
            name: userInfo.name,
            introduction: userInfo.introduction,
            area: userInfo.area,
            profileID: userInfo.profileID,
            likesPerformance: userInfo.likesPerformance,
            reviews: userInfo.reviews.filter { $0.reviewid != review.reviewid }
        )
    }
}

// MARK: - 찜하기
extension UserUseCase {
    func updateLike(_ data: LikesPerformanceModel, isLike: Bool) async throws {
        try await userDS.updateLike(uid: userInfo.uid, like: data, isLike: isLike)
        if isLike {
            userInfo = UserModel(
                uid: userInfo.uid,
                name: userInfo.name,
                introduction: userInfo.introduction,
                area: userInfo.area,
                profileID: userInfo.profileID,
                likesPerformance: userInfo.likesPerformance + [data],
                reviews: userInfo.reviews
            )
        } else {
            userInfo = UserModel(
                uid: userInfo.uid,
                name: userInfo.name,
                introduction: userInfo.introduction,
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
