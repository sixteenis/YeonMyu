//
//  View+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//
import SwiftUI

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

