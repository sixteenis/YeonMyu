//
//  MyView.swift
//  YeonMyu
//
//  Created by 박성민 on 3/24/25.
//

import SwiftUI

struct MyView: View {
    var body: some View {
        ZStack {
            Color.purpleBlueGradient
                .ignoresSafeArea(edges: .top)
            VStack {
                Text("마이")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

#Preview {
    MyView()
}
