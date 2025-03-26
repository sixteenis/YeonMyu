//
//  CustomHorizontalPlayView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/8/25.
//

import SwiftUI

struct CustomHorizontalPlayView: View {
    let post: SimplePostModel
    var body: some View {
        VStack(spacing: 0) {
            CustomPostImage(url: post.postURL)
            
            genreView()
                .frame(height: 17)
                .hLeading()
                .padding(.vertical, 4)
            infoView(image: .calendarIcon, text: "\(post.startDate)~\(post.endDate)")
            infoView(image: .markerIcon, text: post.location)
        }
    }
}

private extension CustomHorizontalPlayView {
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
//    CustomHorizontalPlayView()
//        .frame(width: 120, height: 230)
//}
