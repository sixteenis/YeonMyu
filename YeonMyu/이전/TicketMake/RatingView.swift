//
//  RatingView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//

import SwiftUI
import Cosmos

struct RatingView: UIViewRepresentable {
    @Binding var rating: Double
    
    func makeUIView(context: Context) -> CosmosView {
        let cosmosView = CosmosView()
        cosmosView.settings.fillMode = .half
        cosmosView.settings.starSize = 35
        cosmosView.settings.updateOnTouch = true
        cosmosView.settings.minTouchRating = 0
        cosmosView.settings.filledColor = UIColor(Color.starColor) // 채워진 별 색상
        cosmosView.settings.emptyBorderColor = UIColor(Color.starColor) // 빈 별의 테두리 색상
        cosmosView.settings.filledBorderColor = UIColor(Color.starColor) // 채워진 별 테두리 색상
        
        cosmosView.didFinishTouchingCosmos = { value in
            rating = value
        }
        return cosmosView
    }
    
    func updateUIView(_ uiView: CosmosView, context: Context) {
        uiView.rating = rating
    }
}

struct JustShowRatingView: UIViewRepresentable {
    var rating: Double // 터치로 업데이트를 하지 않기 때문에 단순히 값만 사용
    
    func makeUIView(context: Context) -> CosmosView {
        let cosmosView = CosmosView()
        cosmosView.settings.fillMode = .precise // 별을 부분적으로 채우기 위해 설정
        cosmosView.settings.starSize = 15
        cosmosView.settings.updateOnTouch = false // 터치로 업데이트하지 않도록 설정
        cosmosView.settings.minTouchRating = 0
        cosmosView.settings.filledColor = UIColor(Color.starColor) // 채워진 별 색상
        cosmosView.settings.emptyBorderColor = UIColor(Color.starColor) // 빈 별의 테두리 색상
        cosmosView.settings.filledBorderColor = UIColor(Color.starColor) // 채워진 별 테두리 색상
        cosmosView.rating = rating // 초기값 설정
        
        return cosmosView
    }
    
    func updateUIView(_ uiView: CosmosView, context: Context) {
        uiView.rating = rating // 값에 따라 별이 업데이트되도록 설정
    }
}
