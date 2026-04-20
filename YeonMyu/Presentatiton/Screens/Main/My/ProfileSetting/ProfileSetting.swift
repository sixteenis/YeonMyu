//
//  ProfileSetting.swift
//  YeonMyu
//
//  Created by psm on 4/13/26.
//

import SwiftUI

struct ProfileSetting: View {
    @EnvironmentObject var coordinator: MainCoordinator
    @Environment(UserUseCase.self) private var userUseCase
    
    @State private var selectedProfileIndex: Int = 0
    @State private var scrollPositionID: Int? = 0
    @State private var nickname: String = ""
    @State private var introduction: String = ""
    
    private let maxIntroLength = 70
    private let profiles = Image.asProfileList
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            //                profileCarouselSection
            //                    .padding(.top, 24)
            
            VStack(spacing: 20) {
                nicknameField
                introductionField
            }
            .padding(.horizontal, 16)
            .padding(.top, 32)
            
            bottomButtons
                .padding(.horizontal, 40)
                .padding(.bottom, 32)
        }
        .navigationTitle("프로필 설정")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { saveProfile() } label: {
                    Image.asCheck
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundStyle(Color.asWhite)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear { loadUserInfo() }
        .background {
            Image.asGradientColor
                .resizable()
                .scaledToFill()
                .ignoresSafeArea(edges: .top)
        }
        
    }
}

// MARK: - 프로필 캐러셀
private extension ProfileSetting {
    var profileCarouselSection: some View {
        VStack(spacing: 14) {
            pageIndicator
            
            GeometryReader { geo in
                let itemSize: CGFloat = 80
                let sideItemSize: CGFloat = 56
                let spacing: CGFloat = 14
                let sidePadding = (geo.size.width - itemSize) / 2
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: spacing) {
                        ForEach(0..<profiles.count, id: \.self) { index in
                            let isSelected = index == selectedProfileIndex
                            profiles[index]
                                .resizable()
                                .scaledToFill()
                                .frame(width: itemSize, height: itemSize)
                                .clipShape(Circle())
                                .scaleEffect(isSelected ? 1.0 : CGFloat(sideItemSize / itemSize))
                                .overlay {
                                    if isSelected {
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                    }
                                }
                                .animation(.spring(duration: 0.3), value: selectedProfileIndex)
                                .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, sidePadding)
                    .frame(height: itemSize)
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPositionID)
                .onChange(of: scrollPositionID) { _, newValue in
                    if let newValue { selectedProfileIndex = newValue }
                }
                .onChange(of: selectedProfileIndex) { _, newValue in
                    scrollPositionID = newValue
                }
            }
            .frame(height: 80)
        }
    }
    
    var pageIndicator: some View {
        HStack(spacing: 5) {
            ForEach(0..<profiles.count, id: \.self) { index in
                Circle()
                    .fill(index == selectedProfileIndex ? Color.white : Color.white.opacity(0.35))
                    .frame(width: index == selectedProfileIndex ? 7 : 5,
                           height: index == selectedProfileIndex ? 7 : 5)
                    .animation(.spring(duration: 0.3), value: selectedProfileIndex)
            }
        }
    }
}

// MARK: - 별명 설정
private extension ProfileSetting {
    var nicknameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            asText("별명 설정")
                .font(.boldFont14)
                .foregroundStyle(.white.opacity(0.8))
            
            HStack {
                TextField("별명을 입력해주세요", text: $nickname)
                    .font(.boldFont16)
                    .foregroundStyle(.white)
                    .tint(.white)
                
                if !nickname.isEmpty {
                    Button {
                        nickname = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.system(size: 18))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - 소개글 작성
private extension ProfileSetting {
    var introductionField: some View {
        VStack(alignment: .leading, spacing: 8) {
            asText("소개글 작성")
                .font(.boldFont14)
                .foregroundStyle(.white.opacity(0.8))
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $introduction)
                    .scrollContentBackground(.hidden)
                    .font(.font14)
                    .foregroundStyle(.white)
                    .tint(.white)
                    .frame(height: 130)
                    .padding(12)
                    .background(.white.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                    .onChange(of: introduction) { _, newValue in
                        if newValue.count > maxIntroLength {
                            introduction = String(newValue.prefix(maxIntroLength))
                        }
                    }
                
                if introduction.isEmpty {
                    Text("소개글은 최대 \(maxIntroLength)글자까지 작성 가능합니다.")
                        .font(.font14)
                        .foregroundStyle(.white.opacity(0.4))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
            
            HStack {
                Spacer()
                Text("\(introduction.count)/\(maxIntroLength)")
                    .font(.font12)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - 하단 버튼
private extension ProfileSetting {
    var bottomButtons: some View {
        HStack {
            Button {
                coordinator.presentAlert(.logout(confirmAction: {
                    coordinator.pushAndReset(.login)
                }))
            } label: {
                asText("로그아웃")
                    .font(.font14)
                    .foregroundStyle(.white.opacity(0.6))
            }
            
            Spacer()
            
            Button {
                coordinator.presentAlert(.withdrawMember(confirmAction: {
                    coordinator.pushAndReset(.login)
                }))
            } label: {
                asText("회원탈퇴")
                    .font(.font14)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - 로직
private extension ProfileSetting {
    func loadUserInfo() {
        let user = userUseCase.userInfo
        selectedProfileIndex = user.profileID
        nickname = user.name
        introduction = user.introduction
    }
    
    func saveProfile() {
        coordinator.pop()
    }
}

