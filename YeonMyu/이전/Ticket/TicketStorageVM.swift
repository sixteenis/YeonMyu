//
//  TicketStorageVM.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/22/24.
//

import Foundation
import Combine

final class TicketStorageVM: ViewModeltype {
    var cancellables = Set<AnyCancellable>()
    var input = Input()
    @Published var output = Output()
    struct Input {
        let viewAppear = PassthroughSubject<Void, Never>()
        let selectedPerformance = PassthroughSubject<PerformancePicker, Never>()
        let searchText = CurrentValueSubject<String, Never>("")
        let removeTicket = PassthroughSubject<SaveTicketModel, Never>()
        let RealRemoveTicket = PassthroughSubject<Void, Never>()
        let reviewButtonTap = PassthroughSubject<SaveTicketModel, Never>()
        let acceptReview = PassthroughSubject<UpadteTicketModel, Never>()
    }
    struct Output {
        var selectPerformance = PerformancePicker.all
        var ticketList = [SaveTicketModel]()
        var searchText = ""
        var removeAlert = false
        var removeTicketId = ""
        var showButtonSheet = false
        var writeReivewModel = ""
        var showTitle = ""
    }
    init() {
        transform()
    }
    func transform() {
        input.viewAppear
            .sink { [weak self] _ in
                guard let self else { return }
                self.output.ticketList = self.getTicketList()
            }.store(in: &cancellables)
        input.selectedPerformance
            .sink { [weak self] type in
                guard let self else { return }
                self.output.selectPerformance = type
                self.output.ticketList = getTicketList()
            }.store(in: &cancellables)
        input.searchText
            .debounce(for: .seconds(1), scheduler: RunLoop.main) //실시간 검색어 감지할 경우 이거 키자~
            .sink { [weak self] text in
                guard let self else { return }
                self.output.searchText = text
                self.output.ticketList = getTicketList()
            }.store(in: &cancellables)
        input.removeTicket
            .sink { [weak self] item in
                guard let self else { return }
                self.output.removeAlert.toggle()
                self.output.removeTicketId = item.imageRoute
            }.store(in: &cancellables)
        input.RealRemoveTicket
            .sink { [weak self] item in
                guard let self else { return }
                TicketManager.shared.removeTicket(self.output.removeTicketId)
                if let index = self.output.ticketList.firstIndex(where: { $0.imageRoute == self.output.removeTicketId }) {
                    self.output.ticketList.remove(at: index)
                }
            }.store(in: &cancellables)
        input.reviewButtonTap
            .sink { [weak self] ticket in
                guard let self else { return }
                self.output.showButtonSheet.toggle()
                self.output.writeReivewModel = ticket.imageRoute
                self.output.showTitle = ticket.title
                print(self.output.writeReivewModel)
            }.store(in: &cancellables)
        input.acceptReview
            .sink { [weak self] review in
                guard let self else { return }
                TicketManager.shared.setReviewTicket(self.output.writeReivewModel, rating: review.rationg, review: review.review)
                self.output.ticketList =  self.getTicketList()
                
            }.store(in: &cancellables)
    }
}

private extension TicketStorageVM {
    func getTicketList() -> [SaveTicketModel] {
        let result = TicketManager.shared.getTicketList().map{SaveTicketModel(data: $0)}.filter {
            if self.output.selectPerformance == .all {
                return true
            } else {
                return $0.nowState.title == self.output.selectPerformance.title
            }
        }
        if self.output.searchText == "" {
            return result.reversed()
        } else {
            return result.reversed().filter {$0.title.contains(self.output.searchText)}
        }
    }
}
