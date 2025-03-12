//
//  ReviewView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/30/24.
//

import SwiftUI

struct ReviewView: View {
    @Environment(\.dismiss) var dismiss
    @State var ration = 0.0
    @State var text = ""
    var title: String = ""
    var completion: ((UpadteTicketModel) -> ())?
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .lineLimit(1)
                .font(.font18)
                .asForeground(Color.asFont)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            VStack(alignment: .leading) {
                Text("평점")
                    .font(.boldFont16)
                    .padding(.leading, 5)
                RatingView(rating: $ration)
                    .frame(height: 50)
                Text("후기")
                    .font(.boldFont16)
                    .padding(.leading, 5)
                TextEditor(text: $text)
                    .customStyleEditor(placeholder: "후기를 작성해주세요.", userInput: $text)
                    .frame(height: 150)
                Spacer()
                Button {
                    // Action
                    completion?(UpadteTicketModel(rationg: ration, review: text))
                    dismiss()
                } label: {
                    RoundedRectangle(cornerRadius: 15)
                        .asForeground(Color.asMainColor)
                        .overlay {
                            Text("작성완료")
                                .asForeground(Color.asBoardInFont)
                        }
                }
                .frame(height: 50)
                .padding(.horizontal, 90)
            }
            .padding(.horizontal)
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

