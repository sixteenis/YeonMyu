//
//  TicketView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/13/24.
//

import SwiftUI

struct TicketView: View {
    @Binding var tikcet: SaveTicketModel
    @Binding var widthSize: CGFloat
    @Binding var heightSize: CGFloat
    @Binding var removeState: Bool
    var removeCompletion: (() -> ())?
    var reviewCompletion: (() -> ())?
    var body: some View {
        VStack {
            if tikcet.isReverse {
                HStack {
                    backTicket(ticket: tikcet, widthSize: widthSize, heightSize: heightSize)
                    if removeState {
                        Image.remove
                            .resizable()
                            .asForeground(Color.removeColor)
                        //.offset(x: widthSize / 2, y: -heightSize / 2)
                            .frame(width: 25, height: 30)
                    }
                }
                
            } else {
                HStack {
                    frontTicket(ticket: tikcet, widthSize: widthSize, heightSize: heightSize)
                    if removeState {
                        Image.remove
                            .resizable()
                            .asForeground(Color.removeColor)
                        //.offset(x: widthSize / 2, y: -heightSize / 2)
                            .frame(width: 25, height: 30)
                        
                    }
                }
                
            }
        }
        .scaleEffect(x: tikcet.isReverse ? -1 : 1)
        .frame(width: 200, height: 300)
        .rotation3DEffect(.degrees(tikcet.isReverse ? 180 : 0), axis: (x: 0, y: -1, z: 0))
        .animation(.easeInOut(duration: 0.6), value: tikcet.isReverse)
        .onTapGesture {
            let _ = print(tikcet.isReverse)
            if removeState {
                removeCompletion?()
            } else if tikcet.nowState == .schedule {
                
            } else {
                tikcet.isReverse.toggle()
                
            }
        }
        .frame(width: widthSize, height: heightSize)
    }
}


private extension TicketView {
    func frontTicket(ticket: SaveTicketModel, widthSize: CGFloat, heightSize: CGFloat) -> some View {
        ZStack{
            Rectangle()
                .fill(Color.ticketBackground)
                .cornerRadius(10)
            
            HStack {
                TicketManager.shared.getImage(ticket.imageRoute)
                    .resizable()
                    .frame(width: widthSize / 3, height: heightSize, alignment: .leading)
                    .cornerRadius(10)
                VStack(alignment: .leading) {
                    Text(ticket.title)
                        .asForeground(Color.asFont)
                        .frame(width: widthSize / 2,alignment: .leading)
                        .padding(.bottom, 5)
                    Text(ticket.selectedActors)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    JustShowRatingView(rating: ticket.Rating)
                        .padding(.bottom, 10)
                    if ticket.nowState == .schedule {
                        HStack(alignment: .center) {
                            Spacer()
                                .frame(width: widthSize / 8)
                            RoundedRectangle(cornerRadius: 10)
                                .asForeground(Color.asMainColor)
                                .frame(width: widthSize / 3, height: heightSize / 5)
                                .overlay {
                                    Text("후기 작성")
                                        .asForeground(Color.asBoardInFont)
                                }
                                .wrapToButton {
                                    self.reviewCompletion?()
                                }
                        }
                        .padding(.bottom)
                    }
                }
                .padding([.top,.leading], 10)
                Spacer()
            } //:HSTACK
            
            
        }
        .overlay {
            Circle()
                .fill(Color.asBackground)
                .offset(x: -widthSize * 1.75)
                .scaleEffect(0.3)
            Circle()
                .fill(Color.asBackground)
                .offset(x: widthSize * 1.75)
                .scaleEffect(0.3)
            
            Circle()
                .fill(Color.asBackground)
                .offset(x: -widthSize * 1.7, y: heightSize * 5)
                .scaleEffect(0.1)
            Circle()
                .fill(Color.asBackground)
                .offset(x: -widthSize * 1.7, y: -heightSize * 5)
                .scaleEffect(0.1)
        }
        
        .frame(width: widthSize, height: heightSize)
    }
    func backTicket(ticket: SaveTicketModel, widthSize: CGFloat, heightSize: CGFloat) -> some View {
        let qrSize: CGFloat = widthSize / 4
        return ZStack{
            Rectangle()
                .fill(Color.ticketBackground)
                .cornerRadius(10)
            HStack {
                
                Text(ticket.review)
                    .asForeground(Color.asFont)
                    .font(.font13)
                    .frame(width: widthSize * 0.6, height: heightSize)
                    .padding(.leading, 15)
                lineView()
                VStack(spacing: 10) {
                    Image("QR")
                        .resizable()
                        .frame(width: qrSize,height: qrSize)
                    Text(ticket.code)
                        .asForeground(Color.asSubFont)
                        .font(.font11)
                }
                .padding(.trailing, 15)
                .padding(.leading, 3)
                
                
                
            }
        }
        .overlay {
            Circle()
                .fill(Color.asBackground)
                .offset(x: -widthSize * 1.75)
                .scaleEffect(0.3)
            Circle()
                .fill(Color.asBackground)
                .offset(x: widthSize * 1.75)
                .scaleEffect(0.3)
            
            Circle()
                .fill(Color.asBackground)
                .offset(x: widthSize * 1.7, y: heightSize * 5)
                .scaleEffect(0.1)
            Circle()
                .fill(Color.asBackground)
                .offset(x: widthSize * 1.7, y: -heightSize * 5)
                .scaleEffect(0.1)
        }
        .frame(width: widthSize, height: heightSize)
    }
    func lineView() -> some View {
        lengthLine()
            .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
            .frame(width: 1) // 가로 크기를 고정하고 세로로 길게 표현
            .padding(.vertical, 20) // 세로 방향으로 padding 설정
            .asForeground(Color.ticketLine)
    }
    
    struct lengthLine: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: 0)) // x 좌표 고정, y 좌표 시작
            path.addLine(to: CGPoint(x: rect.midX, y: rect.height)) // x 좌표 고정, y 좌표 끝
            return path
        }
    }
}
