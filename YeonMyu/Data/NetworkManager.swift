//
//  NetworkManager.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/19/24.
//

import Foundation

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    // MARK: - 여러개의 공연 데이터 통신
    func requestPerformance(date: String, genreType: Genre, title: String, page: String) async throws -> [PerformanceDTO] {
        let urlString = APIKey.performanceURL
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key),
            URLQueryItem(name: "stdate", value: date),
            URLQueryItem(name: "eddate", value: date),
            URLQueryItem(name: "cpage", value: page),
            URLQueryItem(name: "rows", value: "10"),
            URLQueryItem(name: "shcate", value: genreType.codeString),
            URLQueryItem(name: "shprfnm", value: title),
            
        ]
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        print(url.absoluteString)
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        let a = response as? HTTPURLResponse
        print(a?.statusCode)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {throw PerformanceError.invalidResponse}
        
        return XMLPerformanceParser().parse(data: data)
    }
    // MARK: - 여러개의 공연 데이터 통신
    func requestPerformance(date: String, cateCode: String, area: String?,title: String, page: Int?, openrun: String?, prfstate: String?) async throws -> [PerformanceDTO] {
        let urlString = APIKey.performanceURL
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key),
            URLQueryItem(name: "stdate", value: date),
            URLQueryItem(name: "eddate", value: date),
            URLQueryItem(name: "cpage", value: String(page ?? 1)),
            URLQueryItem(name: "rows", value: "10"),
            URLQueryItem(name: "shcate", value: cateCode),
            URLQueryItem(name: "shprfnm", value: title),
            URLQueryItem(name: "signgucode", value: area),
        ]
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {throw PerformanceError.invalidResponse}
        return XMLPerformanceParser().parse(data: data)
    }

    // MARK: - 한개의 공연의 디테일한 정보 통신
    func requestDetailPerformance(performanceId id: String) async throws -> DetailPerformanceDTO {
        
        let urlString = APIKey.performanceURL + "/\(id)"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key)
        ]
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw PerformanceError.invalidResponse }
        guard let resultData = XMLDetailPerformanceParser().parse(data: data) else { throw PerformanceError.invalidData}
        
        return resultData
    }
    // MARK: - 공연시설 정보 통신
    func requestFacility(facilityId id: String) async throws -> FacilityDTO {
        let urlString = APIKey.placeURL + "/\(id)"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key)
        ]
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw PerformanceError.invalidResponse }
        return XMLFacilityParser().parse(data: data)
    }
    // MARK: - 박스오피스 (공연 순위) 조회
    func requestBoxOffice(startDate: String, endDate: String, cateCode: String, area: String?) async throws -> [BoxOfficeDTO] {
        let urlString = APIKey.boxofficeURL
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key),
            URLQueryItem(name: "stdate", value: startDate),
            URLQueryItem(name: "eddate", value: endDate),
            URLQueryItem(name: "catecode", value: cateCode),
            URLQueryItem(name: "area", value: area ?? ""),
        ]
        
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw PerformanceError.invalidResponse }
        return BoxOfficeDTOXMLParser().parse(data: data)
    }
    // MARK: - 수상작 조회 (최대 31일)
    func requestAwad(startDate: String, endDate: String, cateCode: String?, area: String?, page: Int?) async throws -> [AwadPerformanceDTO] {
        let urlString = APIKey.awardURL
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "service", value: APIKey.key),
            URLQueryItem(name: "stdate", value: startDate),
            URLQueryItem(name: "eddate", value: endDate),
            URLQueryItem(name: "shcate", value: cateCode ?? ""), //장르코드
            URLQueryItem(name: "area", value: area ?? ""), // 지역 코드
            URLQueryItem(name: "cpage", value: String(page ?? 1)), //현재 페이지
            URLQueryItem(name: "rows", value: "10"), //호출당 목록 수
        ]
        
        guard let url = urlComponents?.url else { throw PerformanceError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { throw PerformanceError.invalidResponse }
        return AwadPerformanceXMLParser().parse(data: data)
    }
}
