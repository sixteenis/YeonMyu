//
//  DateSelectBottomSheetView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/20/25.
//

import SwiftUI

struct DateSelectBottomSheetView: View {
    @Environment(\.dismiss) var dismiss
    let calendar = Calendar.current
    
    
    var body: some View {
        VStack(alignment: .leading) { // VStack을 leading 정렬
            asText("날짜 선택")
                .font(.font20)
                .foregroundStyle(Color.asFont)
                .hLeading()
                .padding(.horizontal, 28)
                .padding(.vertical, 20)
            
            
            
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 50)
                    .foregroundStyle(Color.asPurple300)
                
                asText("완료")
                    .font(.boldFont18)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 22)
            .padding(.top, 24)
            .wrapToButton {
                dismiss()
            }
        }
        Spacer()
    }
    

    
}


#Preview {
    DateSelectBottomSheetView()
}
