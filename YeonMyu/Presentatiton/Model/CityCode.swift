//
//  CityCode.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

enum CityCode: String, CaseIterable {
    case seoul = "서울", busan = "부산", daegu = "대구", incheon = "인천"
    case gwangju = "광주", daejeon = "대전", ulsan = "울산", sejong = "세종"
    case gyeonggi = "경기", gangwon = "강원", chungbuk = "충북", chungnam = "충남"
    case jeonbuk = "전북", jeonnam = "전남", gyeongbuk = "경북", gyeongnam = "경남"
    case jeju = "제주"
    
    var code: String {
        switch self {
        case .seoul: return "11"
        case .busan: return "26"
        case .daegu: return "27"
        case .incheon: return "28"
        case .gwangju: return "29"
        case .daejeon: return "30"
        case .ulsan: return "31"
        case .sejong: return "36"
        case .gyeonggi: return "41"
        case .gangwon: return "51"
        case .chungbuk: return "43"
        case .chungnam: return "44"
        case .jeonbuk: return "45"
        case .jeonnam: return "46"
        case .gyeongbuk: return "47"
        case .gyeongnam: return "48"
        case .jeju: return "50"
        }
    }
}
