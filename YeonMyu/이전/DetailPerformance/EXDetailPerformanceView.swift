//
//  EXDetailPerformanceView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/24/24.
//

import SwiftUI

struct EXDetailPerformanceView: View {
    @State private var activeTap = HeaderType.first
    @Namespace private var animation
    
    @State private var list: [[ShowPerformanceModel]] = []
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(pinnedViews: [.sectionHeaders]) {
                    Section {
                        ForEach(list, id: \.self) { section in
                            exView(list: section)
                        }
                    } header: {
                        scrollableTabs(proxy)
                    }
                }
            }
        }
        .coordinateSpace(name: "CONTENTVIEW")
        .navigationTitle("테스트")
        .onAppear {
            guard list.isEmpty else { return }
            for type in HeaderType.allCases {
                let header = mockUp.filter { $0.type == type }
                list.append(header)
            }
        }
    }
}

#Preview {
    EXDetailPerformanceView()
}

// 탭바 부분 만들기
private extension EXDetailPerformanceView {
    // MARK: - 헤더 뷰 부분
    func scrollableTabs(_ proxy: ScrollViewProxy) -> some View {
        HStack {
            ForEach(HeaderType.allCases, id: \.self) { type in
                Text(type.title)
                    .font(.asMainFont)
                    .background(alignment: .bottom) {
                        if activeTap == type {
                            Capsule()
                                .fill(.red)
                                .frame(height: 5)
                                .padding(.horizontal, -5)
                                .offset(y: 5)
                                .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                        }
                    }
                    .padding()
                    .contentShape(Rectangle())
                    .id(type.tabID)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            activeTap = type
                            // 해당 세션으로 스크롤 해주기
                            proxy.scrollTo(type.tabID, anchor: .top)
                        }
                    }
            }
        }
        .onChange(of: activeTap) { newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                proxy.scrollTo(newValue.tabID, anchor: .top)
            }
        }
    }
}

private extension EXDetailPerformanceView {
    func exView(list: [ShowPerformanceModel]) -> some View {
        VStack(alignment: .leading) {
            if let first = list.first {
                Text(first.type.title)
                    .font(.title)
                    .fontWeight(.semibold)
            }
            ForEach(list, id: \.self) { item in
                Text(item.title)
                    .padding(.bottom, 500)
            }
        }
        .id(list.first?.type.tabID) // list type에 맞는 id 할당
        .offset(y: 0)
        .onAppear {
            // 추가적인 로직이 필요한 경우 이곳에 추가
        }
    }
}
