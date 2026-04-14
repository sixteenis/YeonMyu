//
//  LoadingView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/26/25.
//

import SwiftUI


struct LoadingView: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(Color.asGray300.opacity(0.2))
            .overlay {
                Text("로딩중~~~~")
            }
    }
}
