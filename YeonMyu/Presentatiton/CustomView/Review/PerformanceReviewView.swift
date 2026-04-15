//
//  PerformanceReviewView.swift
//  YeonMyu
//
//  Created by psm on 4/15/26.
//

import SwiftUI

struct PerformanceReviewView: View {
    let review: ReviewModel
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 상단: 이니셜 + 공연 제목 + 화살표
            HStack(spacing: 10) {
                Image.asProfileList[review.userProfileID]
                    .resizable()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 8) {
                        Text(review.userName)
                            .font(.font14)
                            .foregroundColor(.asNewGray600)
                            .lineLimit(1)
                        
                        Text(review.createdAt.asTrasnFormyyyy_mm_dd())
                            .font(.font14)
                            .foregroundColor(.asNewGray400)
                            .lineLimit(1)
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
                    
                }

                Spacer()

                Image.rightArrow
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(.asGray300)
            }

            

            // 후기 텍스트
            Text(review.review)
                .font(.font14)
                .foregroundColor(.asNewGray700)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)

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
