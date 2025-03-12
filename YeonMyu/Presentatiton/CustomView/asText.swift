//
//  asText.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/22/25.
//

import SwiftUI


struct asText : View {
    var title: String
    init(_ title: String) {
        self.title = title
    }
    var body: some View {
        Text(title)
            .tracking(-0.5)
    }
}
