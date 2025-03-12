//
//  SelectGenreView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/12/24.
//

import SwiftUI
struct SelectListView: View {
    @Binding var selected: Genre
    let selectList = Genre.allCases
    var body: some View {
        HStack {
            ForEach(selectList, id: \.self) { type in
                selectGenreButton(type: type)
                    .frame(width: 50) // 각 버튼의 너비 조정
            }
        }
        //.padding(.trailing, 30)
    }
    private func selectGenreButton(type: Genre) -> some View {
        Button {
            selected = type
        } label: {
            VStack(spacing: 5) {
                Text(type.title)
                    .font(.title2)
                    .fontWeight(selected == type ? .bold : .regular)
                    .foregroundStyle(selected == type ? Color.asMainColor : Color.asPlaceholder)
                if selected == type {
                    Rectangle()
                        .frame(width: 40,height: 2)
                        .foregroundColor(.asMainColor)
                }
            }
        }.frame(width: 200)
    }
    
}


