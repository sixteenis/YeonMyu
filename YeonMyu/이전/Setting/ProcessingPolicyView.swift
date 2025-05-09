//
//  ProcessingPolicyView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/30/24.
//

import SwiftUI

struct ProcessingPolicyView: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
        HStack {
            Button {
                dismiss()
                
            } label: {
                Image.xMark
                    .resizable()
                    .frame(width: 20, height: 20)
                    .asForeground(Color.asFont)
            }
            .padding()
            Spacer()
        }
        ScrollView {
            Text("내 안의 연뮤 개인정보 처리방침")
                .font(.boldFont18)
            Spacer()
                .frame(height: 30)
            Text("""
내 안의 연뮤는 「개인정보 보호법」 제30조에 따라 정보주체의 개인정보를 보호하고 이와 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보 처리방침을 수립·공개합니다.

 제1조(개인정보의 처리목적) 내 안의 연뮤는 개인정보 보호법 제32조에 따라 등록․공개하는 개인정보파일의 처리목적은 다음과 같습니다.

 제2조(처리하는 개인정보의 항목) ① 내 안의 연뮤는 개인정보 항목을 처리하고 있지 않습니다.

 제3조(개인정보 파일의 현황) ① 내 안의 연뮤는 개인정보 파일, 쿠키 등을 사용하지 않고, 저장하지 않습니다.

 제4조(개인정보의 처리 및 보유 기간) ① 내 안의 연뮤는 개인정보 파일, 쿠키 등을 사용하지 않고, 저장하지 않습니다. 따라서 이용자의 개인정보를 처리할 내용과 보유기간이 존재하지 않습니다.

 제5조(개인정보의 제3자 제공에 관한 사항) ① 내 안의 연뮤는 개인정보를 제3자에게 제공하지 않습니다.

 제6조(개인정보처리 위탁) ① 내 안의 연뮤는 개인정보의 위탁을 하고 있지 않습니다.

 제7조(정보주체와 법정대리인의 권리·의무 및 그 행사방법에 관한 사항) ① 내 안의 연뮤는 개인정보 파일, 쿠키 등을 사용하지 않고, 저장하지 않습니다.

 제8조(개인정보의 파기) ① 내 안의 연뮤는 독립 실행 방식의 어플리케이션으로 별도의 서버에서 개인정보를 저장하고 있지 않습니다. 따라서 정보주체가 원할 시 어플리케이션을 삭제함으로써 모든 데이터를 파기 가능합니다.
"""
            )
        }
        .padding(.horizontal, 30)
        .scrollIndicators(.hidden)
    }
        
}

#Preview {
    ProcessingPolicyView()
}
