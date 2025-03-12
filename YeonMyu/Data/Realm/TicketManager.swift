//
//  TicketManager.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/29/24.
//

import SwiftUI
import RealmSwift

final class TicketManager {
    private var realm = try! Realm()
    static let shared = TicketManager()
    private init() { }
    
    // MARK: - 저장
    func addTicket(_ model: TicketMakeModel, imageData: Data) {
        let realmModel = TicketList(input: model)
        do {
            try self.realm.write {
                self.realm.add(realmModel)
                self.saveImageToDocument(imageData: imageData, filename: "\(realmModel.id)")
            }
            
        } catch {
            print("저장 실패 ㅜ")
        }
        
    }
    func getTicket(id: String) -> TicketList{
        let realmId = try! ObjectId(string: id)
        try! realm.write {
            if let item = realm.object(ofType: TicketList.self, forPrimaryKey: realmId) {
                return item
            }
            return TicketList()
        }
        return TicketList()
    }
    func getTicketList() -> [TicketList] {
        let list = Array(realm.objects(TicketList.self))
        return list
    }
    // MARK: - 이미지가져오기
    func getImage(_ id: String) -> Image {
        
        return self.loadImageToDocument(filename: id)
        
    }
    func removeTicket(_ id: String) {
        let realmId = try! ObjectId(string: id)
        try! realm.write {
            if let del = realm.object(ofType: TicketList.self, forPrimaryKey: realmId) {
                realm.delete(del)
                self.removeImageFromDocument(filename: id)
            }
        }
    }
    func setReviewTicket(_ id: String, rating: Double, review: String) {
        let realmId = try! ObjectId(string: id)
        let ticket = realm.objects(TicketList.self).where {
            $0.id == realmId
        }.first!
        try! realm.write{
            ticket.nowState = TicketState.completion.title
            ticket.rating = rating
            ticket.review = review
        }
    }
    
}


// MARK: - 파일매니저 부분
private extension TicketManager {
    func saveImageToDocument(imageData: Data, filename: String) {
        guard let document = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return }
        let fileURL = document.appendingPathComponent("\(filename).jpg")
        do {
            try imageData.write(to: fileURL)
        } catch {
            print("file save error!!!!", error)
        }
    }
    
    func loadImageToDocument(filename: String) -> Image {
        guard let document = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return Image.postPlaceholder.resizable() }
        
        let fileURL = document.appendingPathComponent("\(filename).jpg")
        
        // 파일이 존재할 경우
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let uiImage = UIImage(contentsOfFile: fileURL.path) {
                return Image(uiImage: uiImage) // UIImage를 SwiftUI의 Image로 변환
            }
        }
        
        // 파일이 없을 경우 기본 시스템 이미지 반환
        return Image.postPlaceholder
    }
    
    func removeImageFromDocument(filename: String) {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        
        let fileURL = documentDirectory.appendingPathComponent("\(filename).jpg")
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch {
                print("file remove error", error)
            }
            
        } else {
            print("file no exist")
        }
        
    }
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Image download error: \(String(describing: error))")
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
        task.resume()
    }
    func removeAllFilesInDocumentDirectory() {
        guard let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            print("모든 파일이 삭제.")
        } catch {
            print("전체 파일 삭제 중 오류 발생: \(error)")
        }
    }
    
}
