//
//  FacilityDTO.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/19/24.
//

import Foundation

// 공연장 정보 저장 구조체
struct FacilityDTO {
    var fcltynm: String // 시설 이름
    var mt10id: String // 시설 ID
    var mt13cnt: String // 관련 공연장 수
    var fcltychartr: String // 시설 특징
    var opende: String // 오픈 날짜
    var seatscale: String // 좌석 수
    var telno: String // 전화번호
    var relateurl: String // 관련 URL
    var adres: String // 주소
    var la: String // 위도
    var lo: String // 경도
    var restaurant: String // 레스토랑 여부
    var cafe: String // 카페 여부
    var store: String // 상점 여부
    var nolibang: String // 노래방 여부
    var suyu: String // 수유실 여부
    var parkbarrier: String // 장애인 주차장 여부
    var restbarrier: String // 장애인 화장실 여부
    var runwbarrier: String // 장애인 통로 여부
    var elevbarrier: String // 장애인 엘리베이터 여부
    var parkinglot: String // 주차장 여부
    var performancePlaces: [PerformancePlace] // 공연장 세부 정보
    func transformPlaceModel() -> PlaceModel {
        let la = Double(self.la) ?? 37.5666791
        let lo = Double(self.lo) ?? 126.9782914
        let model = PlaceModel(facilityName: self.fcltynm, address: self.adres, latitude: la, longitude: lo)
        return model
    }
}

struct PerformancePlace {
    var prfplcnm: String // 공연장 이름
    var mt13id: String // 공연장 ID
    var seatscale: String // 좌석 수
    var stageorchat: String // 오케스트라 여부
    var stagepracat: String // 리허설 여부
    var stagedresat: String // 드레스 룸 여부
    var stageoutdrat: String // 야외 여부
    var disabledseatscale: String // 장애인 좌석 수
    var stagearea: String // 무대 면적
}

class XMLFacilityParser: NSObject, XMLParserDelegate {
    
    private var currentElement = ""
    private var currentText = ""
    
    private var currentFacility: FacilityDTO = FacilityDTO(
        fcltynm: "",
        mt10id: "",
        mt13cnt: "",
        fcltychartr: "",
        opende: "",
        seatscale: "",
        telno: "",
        relateurl: "",
        adres: "",
        la: "",
        lo: "",
        restaurant: "",
        cafe: "",
        store: "",
        nolibang: "",
        suyu: "",
        parkbarrier: "",
        restbarrier: "",
        runwbarrier: "",
        elevbarrier: "",
        parkinglot: "",
        performancePlaces: []
    )
    private var currentPerformancePlace: PerformancePlace?
    private var performancePlaces: [PerformancePlace] = []
    
    // Parsing 시작
    func parse(data: Data) -> FacilityDTO {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        
        return currentFacility
    }
    
    // XML의 새로운 엘리먼트 시작
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentText = ""
        
        if elementName == "db" {
            // 초기화 필요 없음 (이미 초기화 되어 있음)
            performancePlaces = []
        }
        
        if elementName == "mt13" {
            currentPerformancePlace = PerformancePlace(
                prfplcnm: "",
                mt13id: "",
                seatscale: "",
                stageorchat: "",
                stagepracat: "",
                stagedresat: "",
                stageoutdrat: "",
                disabledseatscale: "",
                stagearea: ""
            )
        }
    }
    
    // XML의 엘리먼트 내용
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // XML의 엘리먼트 끝
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        switch elementName {
        case "fcltynm": currentFacility.fcltynm = currentText
        case "mt10id": currentFacility.mt10id = currentText
        case "mt13cnt": currentFacility.mt13cnt = currentText
        case "fcltychartr": currentFacility.fcltychartr = currentText
        case "opende": currentFacility.opende = currentText
        case "seatscale": currentFacility.seatscale = currentText
        case "telno": currentFacility.telno = currentText
        case "relateurl": currentFacility.relateurl = currentText
        case "adres": currentFacility.adres = currentText
        case "la": currentFacility.la = currentText
        case "lo": currentFacility.lo = currentText
        case "restaurant": currentFacility.restaurant = currentText
        case "cafe": currentFacility.cafe = currentText
        case "store": currentFacility.store = currentText
        case "nolibang": currentFacility.nolibang = currentText
        case "suyu": currentFacility.suyu = currentText
        case "parkbarrier": currentFacility.parkbarrier = currentText
        case "restbarrier": currentFacility.restbarrier = currentText
        case "runwbarrier": currentFacility.runwbarrier = currentText
        case "elevbarrier": currentFacility.elevbarrier = currentText
        case "parkinglot": currentFacility.parkinglot = currentText
        
        // 공연장 정보 처리
        case "prfplcnm": currentPerformancePlace?.prfplcnm = currentText
        case "mt13id": currentPerformancePlace?.mt13id = currentText
        case "seatscale": currentPerformancePlace?.seatscale = currentText
        case "stageorchat": currentPerformancePlace?.stageorchat = currentText
        case "stagepracat": currentPerformancePlace?.stagepracat = currentText
        case "stagedresat": currentPerformancePlace?.stagedresat = currentText
        case "stageoutdrat": currentPerformancePlace?.stageoutdrat = currentText
        case "disabledseatscale": currentPerformancePlace?.disabledseatscale = currentText
        case "stagearea": currentPerformancePlace?.stagearea = currentText
        
        // 공연장 정보 완료 시
        case "mt13":
            if let performancePlace = currentPerformancePlace {
                performancePlaces.append(performancePlace)
            }
        
        // 시설 정보 완료 시
        case "db":
            currentFacility.performancePlaces = performancePlaces
        default:
            break
        }
    }
    
    // XML의 문서 끝
    func parserDidEndDocument(_ parser: XMLParser) {
        print("Parsing completed. Facility: \(currentFacility.fcltynm)")
    }
    
    // 파싱 에러 처리
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("XML parsing error: \(parseError.localizedDescription)")
    }
}
