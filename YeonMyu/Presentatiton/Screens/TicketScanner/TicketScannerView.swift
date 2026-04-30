//
//  TicketScannerView.swift
//  YeonMyu
//
//  Created by 박성민 on 8/10/25.
//

import SwiftUI
import VisionKit
import Vision
import ChatGPTSwift

struct TicketScannerView : View
{
    let cameraService = CameraService()
    @Binding var capturedImage : UIImage?

    @Environment(\.presentationMode) private var presentationMode
    let openAI = ChatGPTAPI(apiKey: APIKey.openAIKey)
    private let performanceDS = PerformanceDataSource()
    
    var body: some View{
        ZStack{
            CameraView(cameraService: cameraService) { result in
                switch result{
                case .success(let photo):
                    if let data = photo.fileDataRepresentation() {
                        capturedImage = UIImage(data: data)
                        presentationMode.wrappedValue.dismiss()
                        
                        if let cgImage = UIImage(data: data)?.cgImage {
                            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                            let request = VNRecognizeTextRequest { request, error in
                                if let error = error {
                                    print("❌ OCR Error: \(error.localizedDescription)")
                                    return
                                }
                                
                                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                                    print("❌ No text found.")
                                    return
                                }
                                var ocrStr = ""
                                for observation in observations {
                                    if let topCandidate = observation.topCandidates(1).first {
                                        print("📄 인식된 텍스트: \(topCandidate.string)")
                                        ocrStr += topCandidate.string + "\n"
                                    }
                                }
                                // MARK: - 공연 티켓 인증에서 openai 호출 및 공연 api 호출 부분
                                Task {
                                    do {
                                        let scanModel = try await sendGPTAI(texts: ocrStr)
                                        let scanRequest = try await performanceDS.fetchPerformances(startDate: scanModel.date, title: scanModel.name)
                                        for i in scanRequest {
                                            print(i)
                                        }
                                    } catch {
                                        print("인증 오류 ㅠ")
                                    }
                                }
                                
                            }
                            
                            request.recognitionLevel = .accurate
                            request.recognitionLanguages = ["ko-KR", "en-US"]
                            request.usesLanguageCorrection = true
                            
                            DispatchQueue.global(qos: .userInitiated).async {
                                do {
                                    try handler.perform([request])
                                } catch {
                                    print("❌ OCR 처리 실패: \(error.localizedDescription)")
                                }
                            }
                        }
                    } else {
                        print("Error: no image data found")
                    }
                case .failure(let err):
                    print(err.localizedDescription)
                }
            }
//            ScannerLineView()
//                .vCenter()
            VStack{
                Spacer()
                Button(action: {
                    cameraService.capturePhoto()
                }, label: {Image(systemName: "circle").font(.system(size: 72)).foregroundColor(.white)})
            }
        } //:VSTACK
    }
}

extension TicketScannerView {
    /// OpenAI에 텍스트 보내기
    func sendGPTAI(texts: String) async throws -> TicketScanResult {
        do {
            let result = try await openAI.sendMessageStream(text: texts, model: .gpt_hyphen_3_period_5_hyphen_turbo, systemText: "보낸 텍스트 중에 공연명, 관람날짜 추출해서 JSON 형식으로 전달해줘 공연명 변수명은 name, 날짜 변수명은 date로 보내줘. 날짜형식은 yyyyMMdd")
            var responseText = ""
            for try await line in result {
                responseText += line
            }
            guard let data = parseJSONResponse(responseText) else { throw "오류" }
            return data
        } catch {
            throw "오류"
        }
    }
    
    
    func parseJSONResponse(_ jsonString: String) -> TicketScanResult? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌ 문자열을 Data로 변환 실패")
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(TicketScanResult.self, from: jsonData)
            return decoded
        } catch {
            print("❌ JSON 디코딩 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    
    
}
