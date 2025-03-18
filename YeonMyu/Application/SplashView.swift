//
//  SplashView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/30/24.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive: Bool = false
    var body: some View {
        if isActive{
//            TabBarView()
//                .accentColor(.asBlack)
            LoginView()
        }else{
            VStack {
                Text("내 안의 연뮤")
                Spacer()
                    .frame(height: 50)
                ProgressView()
                    .frame(width: 100, height: 100) // 크기 설정
                Spacer()
                    .frame(height: 100)
            }
                .font(.largeTitle)
                .asForeground(Color.asMainColor)
                .fontWeight(.heavy)
                .onAppear{
                    withAnimation(.easeInOut(duration: 1.5)){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0){
                            isActive = true
                        }
                    }
                }
        }
    }
}


#Preview {
    SplashView()
}
