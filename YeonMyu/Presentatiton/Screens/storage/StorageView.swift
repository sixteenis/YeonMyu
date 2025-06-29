//
//  StorageView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/24/25.
//

import SwiftUI

struct StorageView: View {
    @StateObject private var vm: StorageVM
    
    init(selected: StorageType) {
        _vm = StateObject(wrappedValue: StorageVM(selected: selected))
    }
    var body: some View {
        VStack {
            inforView()
                .frame(height: 120)
                .padding(.horizontal, 22)
                .padding(.vertical, 6)
                .padding(.bottom, 48)
                .background(Color.blue)
            
            playInfoView()
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
                        .wrapToButton {
                            vm.input.infoTap.send(.likes)
                        }
                    
                    inforLine()
                    
                    oneInforView(title: "관람한 공연", logo: Image.asperformance, result: "2", type: .watched)
                        .frame(maxWidth: .infinity)
                        .wrapToButton {
                            vm.input.infoTap.send(.watched)
                        }
                        
                    inforLine()
                    
                    oneInforView(title: "예정된 티켓", logo: Image.asCircleTicket, result: "1", type: .scheduled)
                        .frame(maxWidth: .infinity)
                        .wrapToButton {
                            vm.input.infoTap.send(.scheduled)
                        }
                        
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
            
        }
        .background(Color.asGray600)
    }
    func playHeader() -> some View {
        VStack {
            asText("찜한 공연")
            asText("18개의 공연을 찜했어요")
        }
    }
    func playScollView() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                
            }
        }
    }
}
