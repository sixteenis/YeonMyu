//
//  TabBarView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/13/24.
//

import SwiftUI

struct TabBarView: View {
    
    var body: some View {
        TabView {
            HomeView.build()
                .tabItem {
                    Image(systemName: "heart")
                }
            MainView()
                .tabItem {
                    Image(systemName: "house")
                }
                
            TicketStorageView()
                .tabItem {
                    Image(systemName: "ticket")
                }
            SettingView()
                .tabItem {  
                    Image(systemName: "gearshape")
                }
        }
    }
}

#Preview {
    TabBarView()
}
