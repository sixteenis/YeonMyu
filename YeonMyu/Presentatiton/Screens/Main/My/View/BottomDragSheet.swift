//
//  BottomDragSheet.swift
//  YeonMyu
//
//  Created by psm on 4/10/26.
//

import SwiftUI

//struct BottomDragSheet: View {
//    @State private var currentOffset: CGFloat = 0
//    @State private var endOffset: CGFloat = 0
//    
//    let sheetHeight: CGFloat = 120 //바텀 시트 높이 설정
//    let sensitivity: CGFloat = 2 //드래그 민감도 (1이 기본, 0.5는 덜 민감, 2는 더 민감)
//    
//    var body: some View {
//        ZStack {
//            GeometryReader { geometry in
//                let sheetPosition = geometry.size.height - sheetHeight
//                VStack {
//                    Capsule()
//                        .fill(Color.gray)
//                        .frame(width: 80, height: 4)
//                        .padding(.top)
//                    
//                    ScrollView{} //여기 바텀시트안에 넣고 싶은 뷰 넣기
//                }
//                .frame(maxWidth: .infinity)
//                .background(Color.white.cornerRadius(30))
//                .offset(y: sheetPosition + currentOffset)
//                .gesture(
//                    DragGesture()
//                        .onChanged { value in
//                            withAnimation(.spring()) {
//                                currentOffset = value.translation.height * sensitivity + endOffset
//                            }
//                        }
//                        .onEnded { value in
//                            withAnimation(.spring()) {
//                                // 큰창
//                                if currentOffset <  -sheetPosition / 2 {
//                                    currentOffset = -sheetPosition
//                                    // 중간 창
//                                } else if currentOffset < -100 {
//                                    currentOffset = -sheetPosition / 2
//                                    // 작은 창
//                                } else {
//                                    currentOffset = 0
//                                }
//                                endOffset = currentOffset
//                            }
//                        }
//                )
//            }
//        }.edgesIgnoringSafeArea(.bottom)
//    }
//    
//}
//
//#Preview {
//    ZStack {
//        Color.gray.ignoresSafeArea()
//        BottomDragSheet()
//    }
//}
