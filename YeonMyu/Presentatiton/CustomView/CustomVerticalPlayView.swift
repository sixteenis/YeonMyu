//
//  CustomVerticalPlayView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/8/25.
//

import SwiftUI

struct CustomVerticalPlayView: View {
    var post: SimplePostModel
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            CustomPostImage(url: post.postURL)
                .frame(width: 60)
            VStack(alignment: .leading, spacing: 0) {
                genreView()
                    .padding(.bottom, 4)
                    .padding(.top, 2)
                infoView(image: .calendarIcon, text: post.fullDate == nil ? post.startDate+"~"+post.endDate: post.fullDate! )
                infoView(image: .markerIcon, text: post.location)
            }
        }.frame(height: 80)
    }
}

private extension CustomVerticalPlayView {
    func genreView() -> some View {
        HStack(spacing: 2) {
            asText(post.getPostString())
                .font(.font10)
                .foregroundStyle(Color.asMainPurple)
                .padding(.horizontal, 5) // 좌우 여백 추가
                .padding(.vertical, 2)   // 상하 여백 추가
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.clear)
                        .stroke(Color.asMainPurple, lineWidth: 1)
                )
            
            asText(post.postTitle)
                .lineLimit(1)
                .font(.boldFont16)
                .foregroundStyle(Color.asTextColor)
                .padding(.trailing, 46)
            
        } //:HSTACK
    }
    func infoView(image: Image, text: String) -> some View {
        HStack(spacing: 2) {
            image
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundStyle(Color.asGray300)
                .padding(.trailing, 2)
            asText(text)
                .lineLimit(1)
                .font(.font12)
                .foregroundStyle(Color.asGray300)
        }
        .hLeading()
    }
}
//#Preview {
//    CustomVerticalPlayView()
//        .frame(height: 80)
//}
