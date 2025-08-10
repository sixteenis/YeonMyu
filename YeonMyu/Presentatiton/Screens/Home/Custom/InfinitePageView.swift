//
//  InfinitePageView.swift
//  YeonMyu
//
//  Created by 박성민 on 7/14/25.
//

import SwiftUI

struct InfinitePageView<C, T>: View where C: View, T: Hashable {
    // 현재 선택된 항목을 바인딩으로 받아옵니다.
    @Binding var selection: T

    // 주어진 선택 항목에서 이전 항목을 계산하는 함수입니다.
    let before: (T) -> T
    // 주어진 선택 항목에서 다음 항목을 계산하는 함수입니다.
    let after: (T) -> T

    // 주어진 선택 항목을 기반으로 뷰를 생성하는 클로저입니다.
    @ViewBuilder let view: (T) -> C

    // 현재 탭의 인덱스를 저장하는 상태 변수입니다.
    @State private var currentTab: Int = 0

    // 뷰의 본체입니다.
    var body: some View {
        // 이전 및 다음 선택 항목을 계산합니다.
        let previousIndex = before(selection)
        let nextIndex = after(selection)
        
        // TabView를 생성하여 선택 항목의 이전, 현재, 다음 항목을 표시합니다.
        TabView(selection: $currentTab) {
            // 이전 선택 항목을 표시하는 뷰입니다.
            view(previousIndex)
                .tag(-1)

            // 현재 선택 항목을 표시하는 뷰입니다.
            view(selection)
                .onDisappear() {
                    // 현재 탭이 변경될 때 선택 항목을 업데이트합니다.
                    if currentTab != 0 {
                        selection = currentTab < 0 ? previousIndex : nextIndex
                        currentTab = 0
                    }
                }
                .tag(0)

            // 다음 선택 항목을 표시하는 뷰입니다.
            view(nextIndex)
                .tag(1)
        }
        // 페이지 인디케이터를 숨기고 페이지 스타일로 TabView를 설정합니다.
        .tabViewStyle(.page(indexDisplayMode: .never))
        // 탭이 0이 아닐 때 스와이프를 비활성화하여 빠른 스와이프 시 발생하는 글리치를 방지합니다.
        .disabled(currentTab != 0) // FIXME: workaround to avoid glitch when swiping twice very quickly
    }
}

//#Preview {
//    InfinitePageView()
//}
