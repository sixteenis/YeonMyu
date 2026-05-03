//
//  UserRepository.swift
//  Domain Layer - 사용자 정보 저장소 추상
//

import Foundation

protocol UserRepository: AnyObject {
    // MARK: - 유저 CRUD
    func fetchUser(uid: String) async throws -> UserModel?
    func createUser(uid: String, name: String, area: String) async throws
    func deleteUser(uid: String) async throws
    func updateUser(uid: String, name: String, introduction: String, area: String, profileID: Int) async throws

    // MARK: - 후기
    func addReview(uid: String, review: ReviewModel) async throws
    func removeReview(uid: String, reviewid: String) async throws

    // MARK: - 찜하기
    func updateLike(uid: String, like: LikesPerformanceModel, isLike: Bool) async throws
}

extension UserDataSource: UserRepository {}
