//
//  SettingView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/13/24.
//

import SwiftUI

struct SettingView: View {
    @State private var setNick = false
    @State private var nick = UserManager.shared.userNick // 초기 닉네임은 유저디폴트에서 가져옴
    @State private var tickets: [TicketList] = [TicketList]()
    @State private var policyView = false
    var body: some View {
        NavigationWrapper {
            GeometryReader { geometry in
                let widthSize = geometry.size.width
                let heightSize = geometry.size.height
                
                    backView(widthSize: widthSize, heightSize: heightSize)
                    .overlay {
                        VStack {
                            Spacer()
                                .frame(height: heightSize * 0.15)
                            profileView()
                                .frame(width: widthSize * 0.8, height: heightSize * 0.15)
                                .padding(.leading)
                            Spacer()
                                .frame(height: heightSize * 0.07)
                            lineView()
                            Spacer()
                                .frame(height: heightSize * 0.08)
                            ticketInforView()
                                .frame(width: widthSize * 0.7, height: heightSize * 0.15)
                            Spacer()
                                .frame(height: heightSize * 0.05)
//                            Button {
//                                // Action
//                                policyView.toggle()
//                            } label: {
//                                HStack {
//                                    Text("개인정보처리방침")
//                                        .padding(.leading, 35)
//                                    Spacer()
//                                    Image(systemName: "greaterthan")
//                                        .padding(.trailing, 35)
//                                }
//                                .asForeground(Color.ticketButtonColor)
//                            }
                            Spacer()
                                .frame(height: heightSize * 0.35)
                            HStack(spacing: 0) {
                                Button {
                                    if let url = URL(string: "https://www.kopis.or.kr") {
                                        UIApplication.shared.open(url)
                                    }
                                    
                                } label: {
                                    VStack {
                                        Text("공연 정보 출처")
                                            .asForeground(Color.ticketButtonColor)
                                            .font(.font12)
                                        Text("(재)예술경영지원센터 공연예술통합전산망")
                                            .asForeground(Color.ticketButtonColor)
                                            .font(.font10)
                                    }
                                }
                                Rectangle()
                                    .frame(width: 1, height: 20)
                                    .padding(.horizontal, 10)
                                    .asForeground(Color.ticketButtonColor)
                                

                                Button {
                                    // Action
                                    policyView.toggle()
                                } label: {
                                    Text("개인정보처리방침")
                                        .asForeground(Color.ticketButtonColor)
                                        .font(.font12)
                                }
                            } //:VSTACK
                            Spacer()
                                .frame(height: heightSize * 0.16)
                                
                        }
                        .padding(30)
                        .fixedSize(horizontal: false, vertical: true) // 높이 고정
                        
                    }
                    
            }
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.keyboard) // 키보드 나타날 때 영향을 받지 않도록 설정
            .onAppear {
                self.tickets = TicketManager.shared.getTicketList()
            }
            .sheet(isPresented: $policyView) {
                ProcessingPolicyView()
            }
            
        }
    }
}

// MARK: - 프로필 뷰
private extension SettingView {
    func profileView() -> some View {
        HStack {
            VStack {
                Spacer()
                    .frame(height: 20)
                
                Text("닉네임")
                    .font(.font16)
                    .asForeground(Color.asBoardInFont)
                    .opacity(0.6)
                    .padding(.leading)
                    .frame(width: 150, alignment: .leading)
                Spacer()
                    .frame(height: 10)
                
                if setNick {
                    TextField(nick, text: $nick)
                        .font(.boldFont18)
                        .asForeground(Color.white)
                        .opacity(0.8)
                        .padding(.leading, 15)
                        .frame(width: 150, alignment: .leading)
                    
                } else {
                    Text(nick)
                        .font(.boldFont18)
                        .asForeground(Color.white)
                        .opacity(0.8)
                        .padding(.leading, 15)
                        .frame(width: 150, alignment: .leading)
                }
            }
            .frame(width: 150,alignment: .leading)
            Spacer()
            profileSetUpButton()
                .padding(.trailing, 30)
                .padding(.top)
        }
    }

    // 프로필 수정/저장 버튼
    func profileSetUpButton() -> some View {
        Button {
            if setNick {
                // 닉네임 저장 로직 (UserDefaults 반영)
                UserManager.shared.userNick = nick // 유저디폴트에 닉네임 저장
            }
            setNick.toggle() // 버튼 클릭 시 닉네임 수정 가능 여부 전환
        } label: {
            RoundedRectangle(cornerRadius: 30)
                .overlay {
                    if setNick {
                        Text("저장하기")
                            .font(.font13)
                            .foregroundStyle(.white)
                            .opacity(0.8)
                    } else {
                        Text("프로필 수정하기")
                            .font(.font13)
                            .foregroundStyle(.white)
                            .opacity(0.8)
                    }
                }
        }
        .frame(width: 100, height: 44)
        .asForeground(Color.ticketButtonColor)
        
    }
}

// MARK: - 선
private extension SettingView {
    func lineView() -> some View {
        Line()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(height: 1)
            .padding(.horizontal, 20)
            .asForeground(Color.ticketLine)
    }

    struct Line: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
            return path
        }
    }
}

// MARK: - 티켓 정보 뷰
private extension SettingView {
    func ticketInforView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.ticketButtonColor)
                .opacity(1.2)
            HStack(spacing: 30) {
                inforView(title: "통합", logo: Image("logo"), result: tickets.count.formatted())
                inforLine()
                inforView(title: "예정", logo: Image("logo"), result: tickets.filter{$0.nowState == "예정"}.count.formatted())
                inforLine()
                inforView(title: "완료", logo: Image("logo"), result: tickets.filter{$0.nowState == "완료"}.count.formatted())
            }
        }
    }

    func inforView(title: String, logo: Image, result: String) -> some View {
        VStack {
            Text(title)
                .asForeground(Color.asBackground)
//            logo
//                .resizable()
//                .asForeground(Color.asBoardInFont)
            Text(result)
                .asForeground(Color.asBackground)
        }
    }

    func inforLine() -> some View {
        Rectangle()
            .frame(width: 1)
            .asForeground(Color.asBackground)
            .padding([.top, .bottom], 25)
    }
}

// MARK: - 배경
private extension SettingView {
    func backView(widthSize: CGFloat, heightSize: CGFloat) -> some View {
        Rectangle()
            .padding([.horizontal, .top], 20)
            .foregroundColor(Color.asMainColor)
            .overlay {
                Circle()
                    .fill(Color.asBackground)
                    .offset(x: -widthSize * 2.5, y: -heightSize * 1.2)
                    .scaleEffect(0.2)
                Circle()
                    .fill(Color.asBackground)
                    .offset(x: widthSize * 2.5, y: -heightSize * 1.2)
                    .scaleEffect(0.2)
                Circle()
                    .fill(Color.asBackground)
                    .offset(y: -heightSize * 2.4)
                    .scaleEffect(0.2)
            }
    }
}

#Preview {
    SettingView()
}
