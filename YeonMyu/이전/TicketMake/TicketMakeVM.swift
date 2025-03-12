//
//  TicketMakeVM.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/29/24.
//
import SwiftUI
import Combine

final class TicketMakeVM: ViewModeltype {
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    private var data = DetailPerformance()
    private let notificationManager = LocalNotificationManager()
    @Published var output = Output()
    struct Input {
        let dataSet = CurrentValueSubject<(DetailPerformance,String), Never>((DetailPerformance(),""))
        let selecetActor = PassthroughSubject<UUID, Never>()
        let ticketPrice = PassthroughSubject<String, Never>() // 티켓 금액 입력
        let saveButtonTap = PassthroughSubject<Void, Never>()
        //let updateTicketSet = CurrentValueSubject<SaveTicketModel, Never>()
    }
    struct Output {
        var data = TicketMakeModel()
        var ticketPrice = ""
        var imageData: Data = .empty
        //var saveButtonTapped = false
        var saveCompletion = false
        
        
    }
    init() {
        transform()
    }
    func transform() {
        input.dataSet
            .sink { [weak self] modle, date in
                guard let self else { return }
                self.output.data = TicketMakeModel(model: modle, date: date)
            }.store(in: &cancellables)
        input.selecetActor
            .sink { [weak self] id in
                guard let self else { return }
                if let index = self.output.data.actors.firstIndex(where: {$0.id == id}) {
                    self.output.data.actors[index].isSelected.toggle()
                }
            }.store(in: &cancellables)
        input.ticketPrice
            .sink { [weak self] str in
                guard let self else { return }
                let num = str.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: "원", with: "")
                print(num)
                if let number = Int(num) {
                    print("실행됨")
                    self.output.ticketPrice = number.formatted() + "원"
                }
                
            }.store(in: &cancellables)
        
        input.saveButtonTap
            .sink { [weak self] _ in
                guard let self else { return }
                print(self.output.data.title)
                //                notificationManager.requestPermission()
                print(self.output.data.state)
                
                DispatchQueue.global().async { [weak self] in
                    guard let self else { return }
                    if self.output.data.state == .schedule {
                        self.notificationManager.addNotification(title: self.output.data.title, date: self.output.data.date)
                        self.notificationManager.schedule()
                    }
                }
                TicketManager.shared.addTicket(self.output.data, imageData: self.output.imageData)
                self.output.saveCompletion = true
            }.store(in: &cancellables)
    }
    
    
}
