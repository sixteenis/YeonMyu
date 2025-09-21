//
//  ADBannerVM.swift
//  YeonMyu
//
//  Created by 박성민 on 7/14/25.
//

import SwiftUI
import Combine

// ADBannerViewModel은 광고 배너의 상태를 관리하는 뷰 모델입니다.
class ADBannerVM: ObservableObject {
    // 현재 선택된 광고 인덱스를 퍼블리시하여 변경 사항을 구독할 수 있게 합니다.
    @Published var adIndex = 0
    
    // 광고 이미지를 제공하는 모델 인스턴스를 생성합니다.
    var model: [MainHeaderPlayModel] = []
    // 타이머를 관리하기 위한 변수입니다.
    private var timer: Timer?
    
    // 광고 이미지 배열을 반환하는 계산 프로퍼티입니다.
    var adImages: [String] {
        return model.map { $0.postURL }
    }

    // 주어진 인덱스를 올바른 범위로 수정하는 함수입니다.
    // 광고 이미지 배열의 길이에 맞춰 인덱스를 순환시킵니다.
    func correctedIndex(for index: Int) -> Int {
        let count = model.count
        if count <= 0 { return 0 }
        return (count + index) % count
    }

    // 자동 스크롤을 시작하는 함수입니다.
    func startAutoScroll() {
        // 기존 타이머가 있으면 중지합니다.
        stopAutoScroll()
        // 3초마다 반복되는 타이머를 설정합니다.
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            // self가 nil이 아니면 강한 참조로 전환하여 사용합니다.
            guard let self = self else { return }
            // 광고 인덱스를 다음 인덱스로 업데이트합니다.
            self.adIndex = self.correctedIndex(for: self.adIndex + 1)
        }
    }
    
    // 자동 스크롤을 중지하는 함수입니다.
    func stopAutoScroll() {
        // 타이머를 무효화하고 nil로 설정합니다.
        timer?.invalidate()
        timer = nil
    }
    func setPage(_ data: [MainHeaderPlayModel]) {
        self.model = data
    }
}
