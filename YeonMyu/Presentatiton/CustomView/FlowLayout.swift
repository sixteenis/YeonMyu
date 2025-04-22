//
//  FlowLayout.swift
//  YeonMyu
//
//  Created by 박성민 on 4/21/25.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat? = nil
    var lineSpacing: CGFloat = 10.0 // 기본 줄 간격을 설정
    
    struct Cache {
        var sizes: [CGSize] = []
        var spacing: [CGFloat] = []
    }
    
    func makeCache(subviews: Subviews) -> Cache {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let spacing: [CGFloat] = subviews.indices.map { index in
            guard index != subviews.count - 1 else {
                return 0
            }
            
            return subviews[index].spacing.distance(
                to: subviews[index+1].spacing,
                along: .horizontal
            )
        }
        
        return Cache(sizes: sizes, spacing: spacing)
    }
    
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) -> CGSize {
        var totalHeight = 0.0
        var totalWidth = 0.0
        
        var lineWidth = 0.0
        var lineHeight = 0.0
        
        for index in subviews.indices {
            if lineWidth + cache.sizes[index].width > proposal.width ?? 0 {
                totalHeight += lineHeight + lineSpacing // 줄 간격 추가
                lineWidth = cache.sizes[index].width
                lineHeight = cache.sizes[index].height
            } else {
                lineWidth += cache.sizes[index].width + (spacing ?? cache.spacing[index])
                lineHeight = max(lineHeight, cache.sizes[index].height)
            }
            
            totalWidth = max(totalWidth, lineWidth)
        }
        
        totalHeight += lineHeight
        
        return .init(width: totalWidth, height: totalHeight)
    }
    
    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Cache
    ) {
        var lineX = bounds.minX
        var lineY = bounds.minY
        var lineHeight: CGFloat = 0
        
        for index in subviews.indices {
            if lineX + cache.sizes[index].width > (proposal.width ?? 0) {
                lineY += lineHeight + lineSpacing // 줄 간격 추가
                lineHeight = 0
                lineX = bounds.minX
            }
            
            let position = CGPoint(
                x: lineX + cache.sizes[index].width / 2,
                y: lineY + cache.sizes[index].height / 2
            )
            
            lineHeight = max(lineHeight, cache.sizes[index].height)
            lineX += cache.sizes[index].width + (spacing ?? cache.spacing[index])
            
            subviews[index].place(
                at: position,
                anchor: .center,
                proposal: ProposedViewSize(cache.sizes[index])
            )
        }
    }
}
