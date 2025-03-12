//
//  BoxOfficeDTO.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct BoxOfficeDTO {
    let prfplcnm: String  // 공연 장소
    let seatcnt: Int      // 좌석 수
    let rnum: Int         // 순번
    let poster: String    // 포스터 URL
    let prfpd: String     // 공연 기간
    let mt20id: String    // 공연 ID
    let prfnm: String     // 공연 이름
    let cate: String      // 카테고리 (뮤지컬, 연극 등)
    let prfdtcnt: Int     // 공연 횟수
    let area: String      // 지역
    
    func transformSimplePostModel() -> SimplePostModel {
        return SimplePostModel(
            postId: self.mt20id,
            postURL: self.poster,
            postType: self.cate,
            postTitle: self.prfnm,
            startDate: self.prfpd,
            endDate: "",
            fullDate: self.prfpd,
            location: self.prfplcnm
        )
    }
}


class BoxOfficeDTOXMLParser: NSObject, XMLParserDelegate {
    var performances: [BoxOfficeDTO] = []
    var currentElement = ""
    var currentPerformance: [String: String] = [:]
    
    func parse(data: Data) -> [BoxOfficeDTO] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        if parser.parse() {
            return performances
        } else {
            return []
        }
    }
    
    // XML 태그가 시작될 때 호출
    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "boxof" {
            currentPerformance = [:]  // 새로운 공연 데이터 초기화
        }
    }

    // 태그 내부 문자열을 읽음
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            currentPerformance[currentElement, default: ""] += trimmedString
        }
    }

    // XML 태그가 닫힐 때 호출
    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName: String?) {
        if elementName == "boxof" {
            if let prfplcnm = currentPerformance["prfplcnm"],
               let seatcnt = Int(currentPerformance["seatcnt"] ?? "0"),
               let rnum = Int(currentPerformance["rnum"] ?? "0"),
               let poster = currentPerformance["poster"],
               let prfpd = currentPerformance["prfpd"],
               let mt20id = currentPerformance["mt20id"],
               let prfnm = currentPerformance["prfnm"],
               let cate = currentPerformance["cate"],
               let prfdtcnt = Int(currentPerformance["prfdtcnt"] ?? "0"),
               let area = currentPerformance["area"] {

                let performance = BoxOfficeDTO(prfplcnm: prfplcnm, seatcnt: seatcnt, rnum: rnum, poster: poster, prfpd: prfpd, mt20id: mt20id, prfnm: prfnm, cate: cate, prfdtcnt: prfdtcnt, area: area)
                
                performances.append(performance)
            }
        }
    }
}
