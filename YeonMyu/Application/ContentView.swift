//
//  ContentView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/23/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator

    var body: some View {
        CoordinatorView()
            .environmentObject(appCoordinator)
    }
}

#Preview {
    ContentView()
}
