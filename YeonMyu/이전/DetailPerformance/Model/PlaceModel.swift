//
//  PlaceModel.swift
//  musicalRecordProject
//
//  Created by 박성민 on 10/7/24.
//

import Foundation
//var fcltynm: String // 시설 이름
//var mt10id: String // 시설 ID
//var mt13cnt: String // 관련 공연장 수
//var fcltychartr: String // 시설 특징
//var opende: String // 오픈 날짜
//var seatscale: String // 좌석 수
//var telno: String // 전화번호
//var relateurl: String // 관련 URL
//var adres: String // 주소
//var la: String // 위도
//var lo: String // 경도
//var restaurant: String // 레스토랑 여부
//var cafe: String // 카페 여부
//var store: String // 상점 여부
//var nolibang: String // 노래방 여부
//var suyu: String // 수유실 여부
//var parkbarrier: String // 장애인 주차장 여부
//var restbarrier: String // 장애인 화장실 여부
//var runwbarrier: String // 장애인 통로 여부
//var elevbarrier: String // 장애인 엘리베이터 여부
//var parkinglot: String // 주차장 여부
//var performancePlaces: [PerformancePlace] // 공연장 세부 정보
struct Facilities {
    let id = UUID().uuidString
    let name: String
    let check: String
    var isChecked: Bool {
        if check == "Y" { return true }
        return false
    }
}
struct PlaceModel {
    var facilityName = ""
    var address = ""
    var latitude = 37.5666791
    var longitude = 126.9782914
    var mt13cnt = ""
    var seatscale = ""
    var amenities: [Facilities] = [] //편의시설 리스트
    var accessibleFacilities: [Facilities] = [] //장애시설 리스트
    
    
//latitude: 37.5666791, longitude: 126.9782914
}


//<dbs>
//    <db>
//        <fcltynm>R&amp;J씨어터(구. 연진아트홀)</fcltynm>
//        <mt10id>FC001142</mt10id>
//        <mt13cnt>1</mt13cnt>
//        <fcltychartr>민간(대학로)</fcltychartr>
//        <opende>2006</opende>
//        <seatscale>127</seatscale>
//        <telno>02-747-1912</telno>
//        <relateurl></relateurl>
//        <adres>서울특별시 종로구 낙산길 14 (동숭동)</adres>
//        <la>37.5802937</la>
//        <lo>127.00526530000002</lo>
//        <restaurant>N</restaurant>
//        <cafe>N</cafe>
//        <store>N</store>
//        <nolibang>N</nolibang>
//        <suyu>N</suyu>
//        <parkbarrier>N</parkbarrier>
//        <restbarrier>N</restbarrier>
//        <runwbarrier>N</runwbarrier>
//        <elevbarrier>N</elevbarrier>
//        <parkinglot>N</parkinglot>
//        <mt13s>
//            <mt13>
//                <prfplcnm>R&amp;J씨어터(구. 연진아트홀)</prfplcnm>
//                <mt13id>FC001142-01</mt13id>
//                <seatscale>127</seatscale>
//                <stageorchat>N</stageorchat>
//                <stagepracat>N</stagepracat>
//                <stagedresat>Y</stagedresat>
//                <stageoutdrat>N</stageoutdrat>
//                <disabledseatscale></disabledseatscale>
//                <stagearea>5.5X7X3.5</stagearea>
//            </mt13>
//        </mt13s>
//    </db>
//</dbs>
