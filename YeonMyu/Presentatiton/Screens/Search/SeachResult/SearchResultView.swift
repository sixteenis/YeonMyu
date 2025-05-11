//
//  SearchResultView.swift
//  YeonMyu
//
//  Created by 박성민 on 4/21/25.
//


import SwiftUI

struct SearchResultView: View {
    var searchText : String
    
    init(searchText: String, date: Date, city: CityCode) {
        self.searchText = searchText
    }
    var body: some View {
        Text(searchText)
    }
}
