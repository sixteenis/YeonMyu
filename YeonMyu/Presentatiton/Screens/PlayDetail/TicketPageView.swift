//
//  TicketPageView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/13/25.
//

import SwiftUI

struct TicketPageView: View {
    var ticketImage: String
    var ticketName: String
    var goticketPageURL: String
    
    var body: some View {
        
        RoundedRectangle(cornerRadius: 30)
            .stroke(Color.asGray400, lineWidth: 1.5)
            .fill(Color.clear)
            .frame(width: 242,height: 48)
            .overlay {
                ticketViewInfo()
            }
            
    }
    private func ticketViewInfo() -> some View {
        HStack {
            Image.exTicket
                .resizable()
                .frame(width: 36, height: 36)
                .padding([.leading, .vertical], 6)
            
            Text(ticketName)
                .font(.font10)
                .foregroundStyle(Color.asGray200)
                .padding(.leading, 4)
            
            Spacer()
            
            Link(destination: URL(string: goticketPageURL)!) {
                asText("바로가기")
                    .font(.boldFont16)
                    .foregroundStyle(Color.asGray300)
                    .padding(.horizontal, 12) // 좌우 여백 추가
                    .padding(.vertical, 8.5)   // 상하 여백 추가
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color.asGray400)
                            
                    )
            }
            .padding(6)
            
        }
    }
}

#Preview {
    TicketPageView(ticketImage: "", ticketName: "예스24티켓", goticketPageURL: "??")
}
