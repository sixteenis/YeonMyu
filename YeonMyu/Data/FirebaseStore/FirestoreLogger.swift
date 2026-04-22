//
//  FirestoreLogger.swift
//  YeonMyu
//

import Foundation
import FirebaseFirestore

// MARK: - DocumentReference 로깅 Extension

extension DocumentReference {

    func loggedGetDocument() async throws -> DocumentSnapshot {
        let startTime = Date()
        do {
            let snapshot = try await self.getDocument()
            FirestoreLogger.log(op: "GET", path: path,
                                requestBody: nil,
                                responseBody: snapshot.data(),
                                elapsed: Date().timeIntervalSince(startTime),
                                error: nil)
            return snapshot
        } catch {
            FirestoreLogger.log(op: "GET", path: path,
                                requestBody: nil,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: error)
            throw error
        }
    }

    func loggedSetData(_ fields: [String: Any], merge: Bool = false) async throws {
        let startTime = Date()
        do {
            try await self.setData(fields, merge: merge)
            FirestoreLogger.log(op: "SET\(merge ? " (merge)" : "")", path: path,
                                requestBody: fields,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: nil)
        } catch {
            FirestoreLogger.log(op: "SET\(merge ? " (merge)" : "")", path: path,
                                requestBody: fields,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: error)
            throw error
        }
    }

    func loggedUpdateData(_ fields: [String: Any]) async throws {
        let startTime = Date()
        do {
            try await self.updateData(fields)
            FirestoreLogger.log(op: "UPDATE", path: path,
                                requestBody: fields,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: nil)
        } catch {
            FirestoreLogger.log(op: "UPDATE", path: path,
                                requestBody: fields,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: error)
            throw error
        }
    }

    func loggedDelete() async throws {
        let startTime = Date()
        do {
            try await self.delete()
            FirestoreLogger.log(op: "DELETE", path: path,
                                requestBody: nil,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: nil)
        } catch {
            FirestoreLogger.log(op: "DELETE", path: path,
                                requestBody: nil,
                                responseBody: nil,
                                elapsed: Date().timeIntervalSince(startTime),
                                error: error)
            throw error
        }
    }
}

// MARK: - FirestoreLogger

enum FirestoreLogger {

    private static let line     = String(repeating: "━", count: 52)
    private static let dashed   = String(repeating: "╌", count: 52)
    private static let pathIcon = "📄"
    private static let bodyIcon = "📦"

    static func log(op: String, path: String,
                    requestBody: [String: Any]?,
                    responseBody: [String: Any]?,
                    elapsed: TimeInterval,
                    error: Error?) {
        let elapsedStr = String(format: "%.3fs", elapsed)
        let statusIcon = error == nil ? "✅" : "❌"

        var rows: [String] = ["┏\(line)"]

        // REQUEST
        rows.append("┃ 📤 REQUEST  ·  \(op)")
        rows.append("┃ \(pathIcon)  \(path)")

        if let requestBody, !requestBody.isEmpty {
            rows.append("┃")
            rows.append("┃ \(bodyIcon)  Body")
            prettyLines(from: requestBody).forEach { rows.append("┃    \($0)") }
        }

        // 구분선
        rows.append("┠\(dashed)")

        // RESPONSE
        if let error {
            rows.append("┃ ❌ RESPONSE  ·  ERROR  ·  ⏱ \(elapsedStr)")
            rows.append("┃    \(error.localizedDescription)")
        } else {
            rows.append("┃ \(statusIcon) RESPONSE  ·  SUCCESS  ·  ⏱ \(elapsedStr)")
            if let responseBody, !responseBody.isEmpty {
                rows.append("┃")
                rows.append("┃ \(bodyIcon)  Body")
                prettyLines(from: responseBody).forEach { rows.append("┃    \($0)") }
            }
        }

        rows.append("┗\(line)")
        print(rows.joined(separator: "\n"))
    }

    private static func prettyLines(from dict: [String: Any]) -> [String] {
        guard let data = try? JSONSerialization.data(withJSONObject: sanitized(dict), options: .prettyPrinted),
              let str = String(data: data, encoding: .utf8)
        else { return ["\(dict)"] }
        return str.components(separatedBy: "\n")
    }

    /// JSONSerialization이 처리 못하는 Firestore 타입(Timestamp, FieldValue 등)을 문자열로 변환
    private static func sanitized(_ value: Any) -> Any {
        switch value {
        case let dict as [String: Any]:
            return dict.mapValues { sanitized($0) }
        case let arr as [Any]:
            return arr.map { sanitized($0) }
        case let ts as Timestamp:
            return ts.dateValue().formatted()
        default:
            if JSONSerialization.isValidJSONObject([value]) { return value }
            return "\(value)"
        }
    }
}
