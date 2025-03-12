//
//  ShowPerformanceModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/25/24.
//

import SwiftUI

struct ShowPerformanceModel: Identifiable, Hashable {
    var id = UUID()
    var type: HeaderType
    var title: String
}
extension [ShowPerformanceModel] {
    var type: HeaderType {
        if let first = self.first { return first.type}
        return .first
    }
    
}
extension View {
    @ViewBuilder
    func offset(_ coordinateSpace: AnyHashable, completion: @escaping (CGRect) -> ()) -> some View {
        self
            .overlay {
                GeometryReader {
                    let rect = $0.frame(in: .named(coordinateSpace))
                    Color.clear
                        .preference(key: OffsetKey.self, value: rect)
                        .onPreferenceChange(OffsetKey.self, perform: completion)
                }
            }
    }
}
extension View {
    @ViewBuilder
    func checkAnimationEnd<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> ()) -> some View {
        self
            .modifier(AnimationEndCallback(for: value, onEnd: completion))
    }
}
fileprivate struct AnimationEndCallback<Value: VectorArithmetic>: Animatable, ViewModifier {
    var animatableData: Value {
        didSet {
            checkIfFinished()
        }
    }
    var endValue: Value
    var onEnd: () -> ()
    init(for value: Value, onEnd: @escaping () -> Void) {
        self.animatableData = value
        self.endValue = value
        self.onEnd = onEnd
    }
    func body(content: Content) -> some View {
        content
    }
    private func checkIfFinished() {
        if endValue == animatableData {
            DispatchQueue.main.async {
                onEnd()
            }
        }
    }
}
//ㅅ크ㅡ롤
struct OffsetKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
var mockUp: [ShowPerformanceModel] = [
    ShowPerformanceModel(type: .first, title: "첫번째 1"),
    ShowPerformanceModel(type: .first, title: "첫번째 2"),
    ShowPerformanceModel(type: .first, title: "첫번째 3"),
    ShowPerformanceModel(type: .second, title: "두번째 1"),
    ShowPerformanceModel(type: .second, title: "두번째 1"),
    ShowPerformanceModel(type: .second, title: "두번째 1"),
    ShowPerformanceModel(type: .third, title: "세번째 1"),
    ShowPerformanceModel(type: .third, title: "세번째 1"),
    ShowPerformanceModel(type: .third, title: "세번째 1"),
]


