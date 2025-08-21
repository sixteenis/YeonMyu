//
//  AuthStep2.swift
//  YeonMyu
//
//  Created by 박성민 on 3/23/25.
//

import SwiftUI

struct AuthStep2: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    var uid: String
    var area: String
    @State private var name: String = ""
    @State private var color = Color.asPurple300
    @State private var alertText = ""
    @State private var isOk = false
    @State private var isCeate = false
    var body: some View {
        NavigationView {
            VStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(Color.asGray400)
                
                // 단계 표시
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.asGray400)
                        .frame(width: 12, height: 12)
                    asText("2")
                        .font(.font14)
                        .foregroundStyle(Color.white)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color.asPurple300)
                        )
                }
                .hCenter()
                .padding([.top, .bottom], 25)
                
                // 안내 텍스트
                asText("앱에서 사용할 별명을 정해주세요")
                    .font(.boldFont20)
                    .bold()
                    .foregroundStyle(Color.asFont)
                    .padding(.bottom, 6)
                asText("별명은 가입 후에도 변경 가능해요")
                    .font(.font16)
                    .foregroundStyle(Color.asGray200)
                    .padding(.bottom, 40)
                
                // 닉네임 입력 필드
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        TextField("6글자 이내로 입력해 주세요", text: $name)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .font(.font20)
                            .foregroundStyle(Color.asFont)
                        
                        xmark()
                    }
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(color)
                    HStack {
                        if !alertText.isEmpty {
                            if isOk {
                                Image.checkIcon
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.checkGreenColor)
                            } else {
                                Image.errIcon
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(Color.errRedColor)
                            }
                        }
                        Text(alertText)
                            .font(.font14)
                            .foregroundStyle(color)
                    }.padding(.leading, -3)
                }
                .padding(.horizontal, 48)
                
                startButton()
                    .vBottom()
            }
            .onChange(of: name) { oldValue, newValue in
                if newValue.isEmpty {
                    self.color = Color.asPurple300
                    self.isOk = false
                    self.alertText = ""
                    return
                }
                if !isValidInput(newValue) {
                    self.color = Color.errRedColor
                    self.isOk = false
                    self.alertText = "영문, 숫자, 한글만 사용 가능합니다."
                    return
                }
                if !countString(newValue) {
                    self.color = Color.errRedColor
                    self.isOk = false
                    self.alertText = "6글자 이내로 별명을 정해주세요"
                    return
                }
                self.color = Color.checkGreenColor
                self.isOk = true
                self.alertText = "사용할 수 있는 별명이에요"
            }
            .onChange(of: isCeate) { oldValue, newValue in
                appCoordinator.pushAndReset(.tab)
            }
        }
    }
}

private extension AuthStep2 {
    func startButton() -> some View {
        Button {
            Task {
                do {
                    let result = try await UserManager.shared.createUser(uid: uid, name: name, area: area)
                    guard let user = result else { return }
                    UserManager.shared.saveUserData(user)
                    self.isCeate = true
                } catch {
                    print("계정 생성 오류 발생!!!")
                }
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 50)
                    .foregroundStyle(isOk ? AnyShapeStyle(Color.purpleBlueGradient)
                                     : AnyShapeStyle(Color.asGray400)
                                     )
                
                asText("시작하기")
                    .font(.boldFont18)
                    .foregroundColor(isOk ? Color.asWhite : Color.asGray300)
            }
        }
        .disabled(!isOk)
        .frame(height: 50)
        .padding(.horizontal, 22)
        .padding(.bottom, 15)
    }
    
    func xmark() -> some View {
        Button(action: {
            print("xmark 버튼 클릭됨") // 디버깅용 로그
            name = ""
        }) {
            Image.xMark
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.asGray400)
        }
        .frame(width: 33, height: 33) // 터치 영역 확장
        .opacity(name.isEmpty ? 0 : 1) // 조건문 대신 opacity로 표시 제어
        .disabled(name.isEmpty) // 비어 있을 때 버튼 비활성화
        .buttonStyle(PlainButtonStyle())
    }
    
    func isValidInput(_ input: String) -> Bool {
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.firstMatch(in: input, options: [], range: range) != nil
    }
    
    func countString(_ input: String) -> Bool {
        return input.count <= 6
    }
}
