//
//  CustomMapMarker.swift
//  musicalRecordProject
//
//  Created by 박성민 on 10/7/24.
//

import SwiftUI

struct CustomMapMarker: View {
    var body: some View {
        VStack(spacing: 0) {
                    Image(systemName: "theatermasks")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.asMainColor)
                        .cornerRadius(36)
                        
                    
                    Image(systemName: "triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.asMainColor)
                        .frame(width: 15, height: 15)
                        .rotationEffect(Angle(degrees: 180))
                        .offset(y: -6)
                        .padding(.bottom, 40)
                }
    }
}

#Preview {
    CustomMapMarker()
}
