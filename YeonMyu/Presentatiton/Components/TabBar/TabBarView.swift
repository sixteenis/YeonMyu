//
//  TabBarView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/13/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var coordinator: MainCoordinator // Coordinator 주입
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            coordinator.build(.home) // 홈 화면 생성
                .tabItem {
                    Image(systemName: "heart")
                    Text("홈")
                }
                .tag(Tab.home)

            coordinator.build(.home) // 산책하기 화면 생성
                .tabItem {
                    Image(systemName: "heart")
                    Text("홈")
                }
                .tag(Tab.dogWalk)

            coordinator.build(.home)
                .tabItem {
                    Image(systemName: "heart")
                    Text("홈")
                }
                .tag(Tab.community)

            coordinator.build(.home)
                .tabItem {
                    Image(systemName: "heart")
                    Text("홈")
                }
                .tag(Tab.chatting)
        }
        .tint(Color.asPurple300)
        .navigationBarBackButtonHidden()

    }
}

//#Preview {
//    MainTabView()
//}
