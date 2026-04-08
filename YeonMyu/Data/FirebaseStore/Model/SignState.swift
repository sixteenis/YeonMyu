//
//  SignState.swift
//  YeonMyu
//
//  Created by 박성민 on 4/6/26.
//

import Foundation

// MARK: - 로그인 상태
enum SignState: String, Identifiable {
    case none
    case signIn
    case newJoin
    case signOut
    case error
    var id: String { self.rawValue }
}
