//
//  CustomSegmentedView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/2/25.
//

import SwiftUI

struct CustomSegmentedView: View {
    
    let segments: [String]
    @Binding var currentPage: Int
    @Namespace private var name
    
    var body: some View {
        ZStack(alignment: .leading) {
            // 배경 애니메이션 (전체 너비를 차지하도록 설정)
                Rectangle()
                    .fill(Color.asMainPurple)
                    .frame(width: UIScreen.main.bounds.width / CGFloat(segments.count), height: 40)
                    .matchedGeometryEffect(id: "Tab", in: name)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2), value: currentPage)
                    .offset(x: CGFloat(currentPage) * (UIScreen.main.bounds.width / CGFloat(segments.count)))
                
            

            HStack(spacing: 0) {
                ForEach(segments.indices, id: \.self) { index in
                    Button {
                        withAnimation {
                            currentPage = index
                        }
                    } label: {
                        ZStack {
                            asText(segments[index])
                                .font(.boldFont18)
                                .fontWeight(.medium)
                                .foregroundColor(currentPage == index ? Color.asWhite : Color.asGray300)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            Rectangle()
                                .frame(height: 2)
                                .foregroundStyle(Color.asBorderGrayLine)
                                .vBottom()
                        }
                            
                    }
                }
            }
            Rectangle()
                .frame(width: UIScreen.main.bounds.width / CGFloat(segments.count), height: 2)
                .foregroundStyle(Color.asMainSecondaryPurple)
                .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0.2), value: currentPage)
                .offset(x: CGFloat(currentPage) * (UIScreen.main.bounds.width / CGFloat(segments.count)))
                .vBottom()
        }
        .frame(height: 40)
        .background(Color.asBorderGray) // 기본 배경 추가
    }
}
//#Preview {
//    struct Preview: View {
//        var segments: [Color] = [.red, .green, .blue]
//        
//        @State var currentPage = 0
//        
//        var body: some View {
//            VStack {
//                CustomSegmentedView(segments: segments.map { "\($0)" },
//                                   currentPage: $currentPage)
//                
//                TabView(selection: $currentPage) {
//                    ForEach(segments.indices, id: \.self) { index in
//                        segments[index]
//                    }
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
//                .scrollTargetBehavior(.paging)
//            }
//            .ignoresSafeArea(.all, edges: .bottom)
//        }
//    }
//    return Preview()
//}
