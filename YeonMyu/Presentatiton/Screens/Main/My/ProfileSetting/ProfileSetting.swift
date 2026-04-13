//
//  ProfileSetting.swift
//  YeonMyu
//
//  Created by psm on 4/13/26.
//

import SwiftUI


struct ProfileSetting: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    @Environment(UserUseCase.self) private var userUseCase
    @State private var isSheetPresented = true
    @MainActor private var navHeight = CGFloat.safeAreaTop + 12 + 28 + 12
    let safeAreaTop: CGFloat = 10
    @State private var profileContentHeight: CGFloat = 300

    // 초기 시트 위치 — BioCardView 하단까지의 실제 높이
    private var initialOffsetY: CGFloat { profileContentHeight }

    @State private var selectedTab = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var stickyOffset: CGFloat = 0
    
    var body: some View {
        VStack {
            Text("프로필 설정")
        }
    }
}
