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
            profileCarouselSection
                .padding(.top, navHeight + 12)

                VStack(spacing: 20) {
                    nicknameField
                    introductionField
                }
                .padding(.horizontal, 16)
                .padding(.top, 32)

            bottomButtons
                .vBottom()
                .padding(.bottom, 32)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
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
                
        }
        .ignoresSafeArea(edges: .vertical)
    }
}

// MARK: - 프로필 캐러셀
private extension ProfileSetting {
    var profileCarouselSection: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(Color.asWhite)
                .frame(width: 8, height: 8)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(0..<profiles.count, id: \.self) { index in
                        profiles[index]
                            .resizable()
                            .scaledToFill()
                            .frame(width: 110, height: 110)
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color.asWhite, lineWidth: 2)
                                    .opacity(index == selectedProfileIndex ? 1 : 0)
                                    .animation(.spring(duration: 0.3), value: selectedProfileIndex)
                            }
                            .scrollTransition(.animated(.spring(duration: 0.3))) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1.3 : 0.85)
                                    .opacity(phase.isIdentity ? 1.0 : 0.55)
                            }
                            .id(index)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $scrollPositionID)
            .contentMargins(.horizontal, (UIScreen.main.bounds.width - 110) / 2)
            .frame(height: 175)
            .onChange(of: scrollPositionID) { _, newValue in
                if let newValue {
                    selectedProfileIndex = newValue
                }
            }
        }
    }
}

// MARK: - 별명 설정
private extension ProfileSetting {
    var nicknameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            asText("별명 설정")
                .font(.font16)
                .foregroundStyle(Color.asWhite)
            
            HStack {
                TextField("별명을 입력해주세요", text: $nickname)
                    .font(.boldFont20)
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
                .font(.font16)
                .foregroundStyle(Color.asWhite)
            
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
            
//            HStack {
//                Spacer()
//                Text("\(introduction.count)/\(maxIntroLength)")
//                    .font(.font12)
//                    .foregroundStyle(.white.opacity(0.5))
//            }
        }
    }
}

// MARK: - 하단 버튼
private extension ProfileSetting {
    var bottomButtons: some View {
        HStack(alignment: .center) {
            Button {
                coordinator.presentAlert(.logout(confirmAction: {
                    userUseCase.logout()
                    coordinator.pushAndReset(.start)
                }))
            } label: {
                asText("로그아웃")
                    .font(.font16)
                    .foregroundStyle(Color.asWhite)
            }
            
            Rectangle()
                .fill(Color.asWhite)
                .frame(width: 1, height: 10)
                .padding(.horizontal, 6)
            
            Button {
                coordinator.presentAlert(.withdrawMember(confirmAction: {
                    Task {
                        do {
                            try await userUseCase.withdraw()
                            coordinator.pushAndReset(.start)
                        } catch {
                            coordinator.presentAlert(.networkError(action: {
                                print("탈퇴 시 오류 발생")
                            }))
                        }
                    }
                    
                }))
            } label: {
                asText("회원탈퇴")
                    .font(.font16)
                    .foregroundStyle(Color.asWhite)
            }
        }
    }
}

// MARK: - 로직
private extension ProfileSetting {
    func loadUserInfo() {
        let user = userUseCase.userInfo
        selectedProfileIndex = user.profileID
        scrollPositionID = user.profileID
        nickname = user.name
        introduction = user.introduction
    }
    
    func saveProfile() {
        Task {
            do {
                let validateResult = nickname.validateNickname()
                // 닉네임 검증
                if validateResult != .valid {
                    coordinator.presentAlert(.validation(title: validateResult.message, action: {
                        print("검증 실패")
                    }))
                    return
                }
                
                if introduction.isEmpty {
                    coordinator.presentAlert(.validation(title: "한줄소개를 입력해 주세요.", action: {
                        print("검증 실패")
                    }))
                    return
                }
                
                var user = userUseCase.userInfo
                user.profileID = selectedProfileIndex
                user.name = nickname
                user.introduction = introduction
                try await userUseCase.updateUserData(user)
                // TODO: 탈퇴 완료 시 성공 팝업? 하단토스트?
                coordinator.pop()
            } catch {
                coordinator.presentAlert(.networkError(action: {
                    print("탈퇴 시 오류 발생")
                }))
            }
            
        }
        
    }
}

