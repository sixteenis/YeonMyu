//
//  NetworkLogger.swift
//  YeonMyu
//

import Foundation

// MARK: - LoggingURLProtocol

/// URLSessionConfiguration에 등록하면 모든 요청/응답을 자동으로 가로채 로그를 남김
final class LoggingURLProtocol: URLProtocol {

    private static let handledKey = "LoggingURLProtocol.handled"

    private var sessionTask: URLSessionDataTask?
    private var startTime = Date()
    private var receivedData = Data()
    private var receivedResponse: URLResponse?

    // 이미 처리된 요청은 무시 (무한 루프 방지)
    override class func canInit(with request: URLRequest) -> Bool {
        return URLProtocol.property(forKey: handledKey, in: request) == nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        startTime = Date()

        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutableRequest)

        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        sessionTask = session.dataTask(with: mutableRequest as URLRequest)
        sessionTask?.resume()
    }

    override func stopLoading() {
        sessionTask?.cancel()
    }
}

extension LoggingURLProtocol: URLSessionDataDelegate {

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        receivedResponse = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            NetworkLogger.log(request: request, response: receivedResponse, data: receivedData, startTime: startTime)
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}

// MARK: - NetworkLogger

enum NetworkLogger {

    /// LoggingURLProtocol이 등록된 URLSession — NetworkManager에서 이 세션만 사용하면 됨
    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.protocolClasses = [LoggingURLProtocol.self]
        return URLSession(configuration: config)
    }()

    static func log(request: URLRequest, response: URLResponse?, data: Data?, startTime: Date) {
        let elapsed = Date().timeIntervalSince(startTime)
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
        print(Format.combined(request: request, statusCode: statusCode, data: data, elapsed: elapsed))
    }
}

// MARK: - Format

private extension NetworkLogger {

    enum Format {

        private static let line     = String(repeating: "━", count: 52)
        private static let dashed   = String(repeating: "╌", count: 52)
        private static let urlIcon  = "🔗"
        private static let keyIcon  = "🔑"
        private static let bodyIcon = "📦"

        static func combined(request: URLRequest, statusCode: Int, data: Data?, elapsed: TimeInterval) -> String {
            let elapsedStr = String(format: "%.3fs", elapsed)
            let statusIcon = icon(for: statusCode)
            let method = request.httpMethod ?? "GET"

            var rows: [String] = ["┏\(line)"]

            // REQUEST
            rows.append("┃ 📤 REQUEST  ·  \(method)")
            rows.append("┃ \(urlIcon)  \(request.url?.absoluteString ?? "-")")

            if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
                rows.append("┃")
                rows.append("┃ \(keyIcon)  Headers")
                headers.sorted(by: { $0.key < $1.key }).forEach {
                    rows.append("┃    \($0.key): \($0.value)")
                }
            }

            if let bodyData = request.httpBody,
               let bodyStr = prettyJSON(from: bodyData) ?? String(data: bodyData, encoding: .utf8),
               !bodyStr.isEmpty {
                rows.append("┃")
                rows.append("┃ \(bodyIcon)  Body")
                bodyStr.components(separatedBy: "\n").forEach { rows.append("┃    \($0)") }
            }

            rows.append("┠\(dashed)")

            // RESPONSE
            rows.append("┃ \(statusIcon) RESPONSE  ·  \(statusCode)  ·  ⏱ \(elapsedStr)")

            if let data, !data.isEmpty {
                let bodyStr = prettyJSON(from: data) ?? prettyXML(from: data) ?? String(data: data, encoding: .utf8)
                if let bodyStr {
                    rows.append("┃")
                    rows.append("┃ \(bodyIcon)  Body")
                    bodyStr.components(separatedBy: "\n").forEach { rows.append("┃    \($0)") }
                }
            }

            rows.append("┗\(line)")
            return rows.joined(separator: "\n")
        }

        private static func icon(for statusCode: Int) -> String {
            switch statusCode {
            case 200..<300: return "✅"
            case 300..<400: return "↩️ "
            case 400..<500: return "⚠️ "
            case 500...:    return "🔥"
            default:        return "❌"
            }
        }

        private static func prettyJSON(from data: Data) -> String? {
            guard let obj = try? JSONSerialization.jsonObject(with: data),
                  let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
            else { return nil }
            return String(data: pretty, encoding: .utf8)
        }

        private static func prettyXML(from data: Data) -> String? {
            guard let raw = String(data: data, encoding: .utf8),
                  raw.trimmingCharacters(in: .whitespaces).hasPrefix("<")
            else { return nil }

            var result = ""
            var indent = 0
            var i = raw.startIndex

            while i < raw.endIndex {
                guard raw[i] == "<" else {
                    // 텍스트 노드
                    let end = raw[i...].firstIndex(of: "<") ?? raw.endIndex
                    let text = raw[i..<end].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !text.isEmpty { result += text }
                    i = end
                    continue
                }

                let tagEnd = raw[i...].firstIndex(of: ">").map(raw.index(after:)) ?? raw.endIndex
                let tag = String(raw[i..<tagEnd])
                i = tagEnd

                let isClosing  = tag.hasPrefix("</")
                let isSelfClose = tag.hasSuffix("/>")
                let isDecl     = tag.hasPrefix("<?") || tag.hasPrefix("<!")

                if isClosing  { indent = max(0, indent - 1) }

                result += "\n" + String(repeating: "  ", count: indent) + tag

                if !isClosing && !isSelfClose && !isDecl { indent += 1 }
            }

            return result.trimmingCharacters(in: .newlines)
        }
    }
}
