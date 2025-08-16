//
//  CustomPostImage.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import SwiftUI
import Kingfisher

struct CustomPostImage: View {
    var url: String
    var size: CGSize? // 직접 크기 지정 가능 (없으면 자동 조정)

    init(url: String, size: CGSize? = nil) {
        self.url = url
        self.size = size
    }

    var body: some View {
        GeometryReader { geometry in
            let baseSize = size ?? geometry.size // 전달된 size가 없으면 자동 조정
            let adjustedSize = CGSize(width: baseSize.width * 1.5, height: baseSize.height * 1.5) // 1.5배 확대
            let processor = DownsamplingImageProcessor(size: adjustedSize) // 리사이징 크기 적용

            KFImage(URL(string: url))
                .retry(maxCount: 3, interval: .seconds(5))
                .loadDiskFileSynchronously()
                .fade(duration: 0.25)
                .setProcessor(processor)
                .resizable()
                .frame(width: baseSize.width, height: baseSize.height) // 원래 프레임 크기 유지
                .clipped() // 확대된 부분이 넘치지 않도록 자르기
        }
    }
}
