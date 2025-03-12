//
//  Location.swift
//  musicalRecordProject
//
//  Created by 박성민 on 10/7/24.
//

import Foundation
import MapKit
struct Location: Identifiable {
    let id = UUID()
    var coordinates: CLLocationCoordinate2D
}
