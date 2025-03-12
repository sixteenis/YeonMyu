//
//  ViewModeltype.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/12/24.
//

import Foundation
import Combine

protocol ViewModeltype: AnyObject, ObservableObject {
    associatedtype Input
    associatedtype Output
    var cancellables: Set<AnyCancellable> { get set }
    
    var input: Input { get set }
    var output: Output { get set }
    
    func transform()
    
}
