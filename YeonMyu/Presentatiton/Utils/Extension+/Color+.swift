//
//  Color+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/12/24.
//

import SwiftUI

extension Color {
    static let asBorderGray = Color.dynamic(light: "F3F3F3", dark: "3A3A3C")
    static let asBorderGrayLine = Color.dynamic(light: "E7E7E7", dark: "4A4A4C")
    static let asGray100 = Color.dynamic(light: "272727", dark: "BEBEC0")
    static let asGray200 = Color.dynamic(light: "595959", dark: "BEBEC0")
    static let asGray300 = Color.dynamic(light: "919193", dark: "BEBEC0")
    static let asGray400 = Color.dynamic(light: "E7E7E7", dark: "BEBEC0")
    static let asGray500 = Color.dynamic(light: "F3F3F3", dark: "BEBEC0")
    static let asText = Color.dynamic(light: "1A1A1A", dark: "BEBEC0")

    static let asMainPurple = Color.dynamic(light: "B086F0", dark: "7D5FB2")
    static let asMainSecondaryPurple = Color.dynamic(light: "9A6BE3", dark: "6A52A5")
    static let asMainPurpleBorder = Color.dynamic(light: "F7EFFF", dark: "322940")
    static let asMainPurpleBorderLine = Color.dynamic(light: "D6B6F8", dark: "5A3C8C")
    static let asPurple200 = Color.dynamic(light: "9A6BE3", dark: "5A3C8C")
    static let asPurple300 = Color.dynamic(light: "B086F0", dark: "5A3C8C")
    static let asPurple500 = Color.dynamic(light: "F7EFFF", dark: "5A3C8C")
    
    static let asWhite = Color.dynamic(light: "FFFFFF", dark: "1C1C1E")
    static let asTextColor = Color.dynamic(light: "595959", dark: "D1D1D3")
    
    static let asBlack = Color.dynamic(light: "000000", dark: "8C66C2")
    static let asMainColor = Color.dynamic(light: "D1B2FF", dark: "8C66C2")
    static let asMainBackground = Color.dynamic(light: "E3C4FF", dark: "5C3D99")
    static let asPlaceholder = Color.dynamic(light: "C0C0C0", dark: "8D8D8F")
    
    static let asFont = Color.dynamic(light: "242424", dark: "E5E5E7")
    static let asWhitePurple = Color.dynamic(light: "EBD9FF", dark: "E5E5E7")
    static let asBackground = Color.dynamic(light: "FFFFFF", dark: "000000")
    static let asSubFont = Color.dynamic(light: "666666", dark: "BBBBBB")
    
    static let logoColor = Color.dynamic(light: "000000", dark: "FFFFFF")
    static let asBoardInFont = Color.dynamic(light: "FFE8FF", dark: "4D2752")
    static let asGrayFont = Color.dynamic(light: "A0A0A0", dark: "C7C7C9")
    
    static let grayBackground = Color.dynamic(light: "F5F5F5", dark: "1C1C1E")
    static let ticketBackground = Color.dynamic(light: "F3E8FF", dark: "33264D")
    static let starColor = Color.dynamic(light: "D1B2FF", dark: "6E4AAE")
    static let ticketLine = Color.dynamic(light: "E6D7FF", dark: "5B3F92")
    
    static let asredColor = Color.dynamic(light: "FF4D4F", dark: "D73232")
    static let removeColor = Color.dynamic(light: "D32F2F", dark: "B22222")
    static let ticketButtonColor = Color.dynamic(light: "5C3D99", dark: "2E1F66")
    
    static let errRedColor = Color.dynamic(light: "FC6363", dark: "2E1F66")
    static let checkGreenColor = Color.dynamic(light: "6AC579", dark: "2E1F66")
}

extension Color {
    /// HEX 색상을 다크모드에 맞게 동적으로 반환하는 함수
    static func dynamic(light: String, dark: String) -> Color {
            return Color(uiColor: UIColor { traitCollection in
                return traitCollection.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
            })
    }
    
    /// HEX 문자열을 Color로 변환하는 생성자
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >>  8) & 0xFF) / 255.0
        let b = Double((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let g = CGFloat((rgb >>  8) & 0xFF) / 255.0
        let b = CGFloat((rgb >>  0) & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
