//
//  RecentSearch.swift
//  YeonMyu
//
//  Created by 박성민 on 4/21/25.
//

import Foundation
import RealmSwift

class RecentSearch: Object {
    @Persisted(primaryKey: true) var _id: String
    @Persisted var seachList: List<String>
    
    
}
