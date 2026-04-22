//
//  TicketPageView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/13/25.
//

import SwiftUI

struct TicketPageView: View {
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
            getTickInfoImage(name: ticketName)
                .resizable()
                .frame(width: 36, height: 36)
                .padding([.leading, .vertical], 6)
                .clipShape(Circle())
            
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
    private func getTickInfoImage(name: String) -> Image {
        switch name {
        case "쿠팡": Image.ticketProviderCoupang
        case "NHN티켓링크": Image.ticketProviderTicketLink
        case "네이버N예약": Image.ticketProviderNaver
        case "놀유니버스": Image.ticketProviderNol
        case "예스24": Image.ticketProviderYes24
        default: Image.ticketProviderDefault
        }
    }
}

#Preview {
    TicketPageView(ticketName: "예스24티켓", goticketPageURL: "??")
}
