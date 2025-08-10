//
//  StorageView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/24/25.
//

import SwiftUI

struct StorageView: View {
    @StateObject private var vm: StorageVM
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    
    init(selected: StorageType) {
        _vm = StateObject(wrappedValue: StorageVM(selected: selected))
    }
    var body: some View {
        VStack(spacing: 0) {
            Text("보관함")
                .font(.headline)
                .hCenter()
            ZStack(alignment: .bottom) {
                inforView()
                    .frame(height: 120)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .padding(.top, 6)
                    .background(Color.asBackground)
                // TODO: 경계 그림자 주기 ㅠㅠ...
                // 하단 경계 + 그림자
                Rectangle()
                    .fill(Color.black.opacity(0.01)) // 그림자만 생성
                    .frame(height: 1)
                    .shadow(color: .black.opacity(0.5), radius: 5, y: 4)
            }

            playInfoView()
                .background(Color.asGray600)
        }
        .onAppear {
            vm.coordinator = coordinator
        }
    }
}



private extension StorageView {
    func inforView() -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.asMainPurpleBorder)
            .stroke(Color.asMainPurpleBorderLine, lineWidth: 1.5)
            .overlay{
                HStack(spacing: 0) {
                    
                    oneInforView(title: "찜한 공연", logo: Image.asHeart, result: "10", type: .likes)
                        .frame(maxWidth: .infinity)
                    
                    inforLine()
                    
                    oneInforView(title: "관람한 공연", logo: Image.asperformance, result: "2", type: .watched)
                        .frame(maxWidth: .infinity)
                    
                    
                    inforLine()
                    
                    oneInforView(title: "예정된 티켓", logo: Image.asCircleTicket, result: "1", type: .scheduled)
                        .frame(maxWidth: .infinity)
                    
                    
                }
            }
    }
    func oneInforView(title: String, logo: Image, result: String, type: StorageType) -> some View {
        Rectangle()
            .fill(Color.clear)
            .overlay {
                VStack {
                    logo
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(vm.output.selectedStorageType == type ? Color.asPurple300 : Color.asPurple300.opacity(0.3) )
                    asText(title)
                        .asForeground(vm.output.selectedStorageType == type ? Color.asTextColor : Color.asTextColor.opacity(0.3))
                        .font(.font12)
                    
                    asText(result)
                        .asForeground(vm.output.selectedStorageType == type ? Color.asTextColor : Color.asTextColor.opacity(0.3))
                        .font(.boldFont28)
                }
            }
            .wrapToButton {
                vm.input.infoTap.send(type)
            }
    }
    
    func inforLine() -> some View {
        Rectangle()
            .frame(width: 1)
            .asForeground(Color.asMainPurpleBorderLine)
            .padding([.top, .bottom], 15)
    }
}

private extension StorageView {
    func playInfoView() -> some View {
        VStack {
            playHeader()
            playScollView()
        }
    }
    func playHeader() -> some View {
        VStack {
            asText("찜한 공연")
                .font(.boldFont20)
                .foregroundStyle(Color.asFont)
                .hLeading()
                .padding([.top,.leading],24)
            asText("18개의 공연을 찜했어요")
                .font(.font14)
                .foregroundStyle(Color.asGray300)
                .hLeading()
                .padding(.leading, 24)
                .padding(.bottom, 12)
        }
        
    }
    func playScollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(vm.output.scrollPostData, id: \.id) { post in
                    CustomVerticalPlayView(post: post)
                        .padding([.leading, .bottom], 24)
                        .wrapToButton {
                            vm.input.postTapped.send(post.postId)
                        }
                }
            }
        }
    }
}
