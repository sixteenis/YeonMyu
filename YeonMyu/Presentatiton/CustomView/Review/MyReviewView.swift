//
//  MyReviewView.swift
//  YeonMyu
//
//  Created by psm on 4/15/26.
//

import SwiftUI

struct MyReviewView: View {
    let review: ReviewModel
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단: 이니셜 + 공연 제목 + 화살표
            HStack(spacing: 10) {
                PerformanceTagView(tagTT: review.genreType.tagText, tagType: .normal)

                Text(review.postTitle)
                    .font(.boldFont16)
                    .foregroundColor(.asTextColor)
                    .lineLimit(1)

                Spacer()

                Image.rightArrow
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.asGray300)
            }

            // 별점
            HStack(spacing: -2) {
                ForEach(1...5, id: \.self) { index in
                    if index <= review.rating {
                        Image.asFillRoundStar
                            .resizable()
                            .frame(width: 20, height: 20)
                    } else {
                        Image.asRoundStar
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
            }

            // 후기 텍스트
            Text(review.review)
                .font(.font14)
                .foregroundColor(.asGray200)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 닉네임 | 날짜
            HStack(spacing: 8) {
                Text(review.userName)
                    .font(.font12)
                    .foregroundColor(.asGray300)
                Text("|")
                    .font(.font12)
                    .foregroundColor(.asGray300)
                Text(review.createdAt.asTrasnFormyyyy_mm_dd())
                    .font(.font12)
                    .foregroundColor(.asGray300)
            }
        }
        .padding(20)
        .background(Color.asWhite)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.asGray400, lineWidth: 1)
        )
        .onTapGesture { onTap?() }
    }
}
