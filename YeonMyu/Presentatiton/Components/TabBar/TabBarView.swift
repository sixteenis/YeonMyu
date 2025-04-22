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
                    Image.home
                    Text("홈")
                }
                .ignoresSafeArea(edges: .top)
                .tag(Tab.home)
            
            // Search tab now just contains a placeholder view
            Color.clear
                .tabItem {
                    Image.search
                    Text("검색")
                }
                .tag(Tab.search)
                .onChange(of: coordinator.selectedTab) { oldValue, newValue in
                    if newValue == .search {
                        // Reset tab to previous one and push search view
                        coordinator.selectedTab = oldValue
                        coordinator.push(.search)
                    }
                }
            
            
            coordinator.build(.storage) // 보관함 화면 생성
                .tabItem {
                    Image.storage
                    Text("보관함")
                }
                .tag(Tab.storage)
            
            coordinator.build(.my) //마이 화면 생성
                .tabItem {
                    Image.my
                    Text("마이")
                }
                .tag(Tab.my)
        }
        .tint(Color.asPurple300)
        .navigationBarBackButtonHidden()
        
    }
}

//#Preview {
//    MainTabView()
//}
