//
//  CoordinatorView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/22/25.
//

import SwiftUI

struct CoordinatorView: View {
    @EnvironmentObject var appCoordinator: MainCoordinator
    
    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            appCoordinator.build(appCoordinator.rootScreen)
                .navigationDestination(for: Screen.self) { screen in
                    appCoordinator.build(screen)
                }
                .sheet(item: $appCoordinator.sheet) { sheet in
                    appCoordinator.build(sheet)
                }
//                .fullScreenCover(item: $appCoordinator.fullScreenCover) { fullScreenCover in
//                    appCoordinator.build(fullScreenCover)
//                }
        }
    }
}
