//
//  Image+.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/14/24.
//

import SwiftUI

extension Image {
    //탭 이미지
    
    static let search = Image("검색")
    static let home = Image("홈")
    static let storage = Image("보관함")
    static let my = Image("마이")
    
    static let remove = Image(systemName: "trash")
    static let xMark = Image("닫기")
    static let asBell = Image("bell")
    static let asBellGray = Image("bell_gray")
    
    
    
    static let calendarIcon = Image("날짜")
    static let markerIcon = Image("지도")
    
    static let asHeart = Image("찜한공연")
    static let asperformance = Image("관람한 공연")
    static let asCircleTicket = Image("예매한 티켓")
    
    //로고
    static let logo = Image("logo")
    static let logoTitle = Image("logo+Title")
    static let logoS = Image("로고조합 S사이즈")
    static let logoM = Image("로고조합 M사이즈")
    static let logoL = Image("로고조합 L사이즈")
    
    
    // 꼬리 없는 화살표
    static let upArrow = Image("위 1")
    static let downArrow = Image("아래 1")
    static let leftArrow = Image("왼쪽 1")
    static let rightArrow = Image("오른쪽 1")
    
    // 꼬리 있는 화살표
    static let upTailArrow = Image("위 2")
    static let downTailArrow = Image("아래 2")
    static let leftTailArrow = Image("왼쪽 2")
    static let rightTailArrow = Image("오른쪽 2")
    
    
    static let postPlaceholder = Image("postPlaceholder")
    static let calendarImage = Image(systemName: "calendar")
    static let exPost = Image("testImage")
    static let downImage = Image(systemName: "chevron.down")
    static let upImage = Image(systemName: "chevron.up")
    static let ticketPlus = Image("ticketPlus")
    
    //로그인 이미지
    static let googleLogin = Image("googleLogin")
    static let appleLogin = Image("appleLogin")
    static let kakaoLogin = Image("kakaoLogin")
    static let loginText = Image("로그인문구")
    static let checkIcon = Image("check")
    static let errIcon = Image("err")
    
    
    
}

extension UIImage {
    static let leftTailArrow = UIImage(named: "왼쪽 2")
}
