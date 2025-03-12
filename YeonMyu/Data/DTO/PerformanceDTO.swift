//
//  PerformanceDTO.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/19/24.
//

import Foundation
// 공연 정보를 저장할 구조체
struct PerformanceDTO {
    let mt20id: String // 공연 id
    let prfnm: String // 공연 이름
    let prfpdfrom: String // 시작 날짜
    let prfpdto: String // 종료 날짜
    let fcltynm: String // 공연 위치
    let poster: String // 포스터 주소
    let area: String // 지역
    let genrenm: String // 공연 종류
    let openrun: String // ?
    let prfstate: String // 상태
    func transformperformanceModel() -> PerformanceModel {
        let playDate = "\(self.prfpdfrom) ~ \(self.prfpdto)"
        let model = PerformanceModel(simple: SimplePerformance(playId: mt20id, playDate: playDate, title: prfnm, place: fcltynm, postURL: poster), detail: DetailPerformance())
        return model
    }
    func transformSimplePostModel() -> SimplePostModel {
        return SimplePostModel(
            postId: self.mt20id,
            postURL: self.poster,
            postType: self.genrenm,
            postTitle: self.prfnm,
            startDate: String(self.prfpdfrom.dropFirst(2)),
            endDate: String(self.prfpdto.dropFirst(2)),
            location: self.fcltynm
        )
    }
}


class XMLPerformanceParser: NSObject, XMLParserDelegate {
    private var performances: [PerformanceDTO] = []
    private var currentElement = ""
    private var currentPerformance: PerformanceDTO?
    
    // 임시 변수들
    private var mt20id = ""
    private var prfnm = ""
    private var prfpdfrom = ""
    private var prfpdto = ""
    private var fcltynm = ""
    private var poster = ""
    private var area = ""
    private var genrenm = ""
    private var openrun = ""
    private var prfstate = ""

    // 파싱 시작
    func parserDidStartDocument(_ parser: XMLParser) {
        performances = []
    }

    // 새로운 요소를 발견했을 때 호출
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if currentElement == "db" {
            // 새로운 공연 정보를 시작
            mt20id = ""
            prfnm = ""
            prfpdfrom = ""
            prfpdto = ""
            fcltynm = ""
            poster = ""
            area = ""
            genrenm = ""
            openrun = ""
            prfstate = ""
        }
    }

    // 요소의 내용을 처리
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedString.isEmpty {
            switch currentElement {
            case "mt20id": mt20id += trimmedString
            case "prfnm": prfnm += trimmedString
            case "prfpdfrom": prfpdfrom += trimmedString
            case "prfpdto": prfpdto += trimmedString
            case "fcltynm": fcltynm += trimmedString
            case "poster": poster += trimmedString
            case "area": area += trimmedString
            case "genrenm": genrenm += trimmedString
            case "openrun": openrun += trimmedString
            case "prfstate": prfstate += trimmedString
            default: break
            }
        }
    }

    // 요소가 끝났을 때 호출
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "db" {
            // 공연 정보를 완성하고 배열에 추가
            let performance = PerformanceDTO(mt20id: mt20id, prfnm: prfnm, prfpdfrom: prfpdfrom, prfpdto: prfpdto, fcltynm: fcltynm, poster: poster, area: area, genrenm: genrenm, openrun: openrun, prfstate: prfstate)
            performances.append(performance)
        }
    }

    // 파싱 완료
//    func parserDidEndDocument(_ parser: XMLParser) {
//        print("파싱 완료: \(performances.count)개의 공연 정보를 가져왔습니다.")
//        for performance in performances {
//            print(performance)
//        }
//    }

    // 에러 발생 시 호출
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("파싱 에러: \(parseError.localizedDescription)")
    }
    
    // 파싱 시작 메서드
    func parse(data: Data) -> [PerformanceDTO]{
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return performances
    }
}
