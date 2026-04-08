//
//  AwadPerformanceDTO.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

struct AwadPerformanceDTO {
    let mt20id: String // 공연 ID
    let prfnm: String // 공연 이름
    let prfpdfrom: String // 시작 날짜
    let prfpdto: String // 종료 날짜
    let fcltynm: String // 공연 장소
    let poster: String // 포스터 URL
    let genrenm: String // 공연 장르
    let prfstate: String // 공연 상태
    let awards: String // 수상 내역
}

class AwadPerformanceXMLParser: NSObject, XMLParserDelegate {
    private var performances: [AwadPerformanceDTO] = []
    private var currentElement = ""
    private var currentPerformance: [String: String] = [:]

    func parse(data: Data) -> [AwadPerformanceDTO] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return performances
    }

    // XML 요소 시작
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "db" {
            currentPerformance = [:] // 공연 정보 초기화
        }
    }

    // XML 요소 내용 처리
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedString.isEmpty {
            currentPerformance[currentElement, default: ""] += trimmedString
        }
    }

    // XML 요소 종료
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "db" {
            if let mt20id = currentPerformance["mt20id"],
               let prfnm = currentPerformance["prfnm"],
               let prfpdfrom = currentPerformance["prfpdfrom"],
               let prfpdto = currentPerformance["prfpdto"],
               let fcltynm = currentPerformance["fcltynm"],
               let poster = currentPerformance["poster"],
               let genrenm = currentPerformance["genrenm"],
               let prfstate = currentPerformance["prfstate"],
               let awards = currentPerformance["awards"] {
                
                let performance = AwadPerformanceDTO(mt20id: mt20id,
                                                 prfnm: prfnm,
                                                 prfpdfrom: prfpdfrom,
                                                 prfpdto: prfpdto,
                                                 fcltynm: fcltynm,
                                                 poster: poster,
                                                 genrenm: genrenm,
                                                 prfstate: prfstate,
                                                 awards: awards)
                performances.append(performance)
            }
        }
    }
}
