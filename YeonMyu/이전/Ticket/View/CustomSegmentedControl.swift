//
//  CustomSegmentedControl.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/14/24.
//

import SwiftUI
struct CustomSegmentedControl: View {
    @Binding var selected: PerformancePicker
    let width: CGFloat
    private let selectList = PerformancePicker.allCases
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ForEach(selectList, id: \.self) { type in
                    selectGenreButton(type: type)
                        .frame(width: width / 3) // 각 버튼의 너비 조정
                }
            } //:HSTACK
            .frame(maxWidth: width)
            Divider()
        } //:VSTACK
        //.padding(.trailing, 30)
    }
    private func selectGenreButton(type: PerformancePicker) -> some View {
        Button {
            selected = type
        } label: {
            VStack(spacing: 5) {
                Text(type.title)
                    .font(.title3)
                    .fontWeight(selected == type ? .bold : .regular)
                    .foregroundStyle(selected == type ? Color.asMainColor : Color.asPlaceholder)
                if selected == type {
                    Rectangle()
                        .frame(width: width / 4,height: 2)
                        .foregroundColor(.asMainColor)
                }
            }
        }.frame(width: width / 3)
    }
    
}
//#Preview {
//    CustomSegmentedControl()
//}
