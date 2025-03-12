//
//  MainVM.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/21/24.
//

import Foundation
import Combine


final class MainVM: ViewModeltype {
    var cancellables: Set<AnyCancellable>
    var input = Input()
    private var page = 1
    private var isPageCan = true
    @Published var output = Output()
    
    init() {
        self.cancellables = Set<AnyCancellable>()
        transform()
    }
    
    struct Input {
        let viewOnTask = PassthroughSubject<Void,Never>()
        let dateSet = CurrentValueSubject<Date, Never>(Date()) //날짜 선택
        let showTypeSet = CurrentValueSubject<Genre, Never>(.play) // 공연 타입 선택
        let selectCell = CurrentValueSubject<UUID, Never>(UUID()) // 셀 클릭 시
        
        let searchTextTap = CurrentValueSubject<String, Never>("") // 키보드 텍스트 값
        let searchTypeTap = CurrentValueSubject<Bool, Never>(false)
        let showLastItem = PassthroughSubject<PerformanceModel, Never>()
        
    }
    struct Output {
        var setDate = Date() //날짜 세팅
        var showType = Genre.play // 공연 타입 세팅
        var selectCellId: UUID = UUID() // 현재 선택한 셀
        var showDatas = [PerformanceModel]() // 현재 공연 데이터들
        var searchText = ""
        var searchType = false
        var selectPost = DetailPerformance()
        var selectDate = ""
    }
    func transform() {
        input.viewOnTask // 뷰가 뜰때
            .sink { [weak self] _ in
                guard let self else { return }
                self.viewOnTask()
            }.store(in: &cancellables)
        input.dateSet //날짜 변경
            .sink { [weak self] date in
                guard let self else { return }
                //날짜를 선택해서 변경시 하루가 감소해서 준다/??
                self.output.setDate = date
                self.seleectDateOrType()
            }.store(in: &cancellables)
        input.showTypeSet //타입 변경
            .sink { [weak self] type in
                guard let self else { return }
                self.output.showType = type
                self.seleectDateOrType()
            }.store(in: &cancellables)
        
        input.selectCell
            .sink { [weak self] id in
                guard let self else { return }
                checkDetailPerformancData(id: id)
            }.store(in: &cancellables)
        
        //서치바 리턴 할 경우
        input.searchTextTap
        //.debounce(for: .seconds(1), scheduler: RunLoop.main) //실시간 검색어 감지할 경우 이거 키자~
            .sink { [weak self] text in
                guard let self else { return }
                self.output.searchText = text
                self.seleectDateOrType()
            }.store(in: &cancellables)
        //검색 타입 선택 시
        input.searchTypeTap
            .sink { [weak self] type in
                guard let self else { return }
                self.output.searchType = type
                if !type { // 날짜로 보기 선택 시 텍스트 초기화
                    self.output.searchText = ""
                    self.seleectDateOrType()
                } else {
                    self.output.showDatas = [PerformanceModel]()
                }
            }.store(in: &cancellables)
        input.showLastItem
            .sink { [weak self] item in
                guard let self else { return }
                let index = self.output.showDatas.count
                if index >= 5 && self.output.showDatas[index - 4].id == item.id {
                    if self.isPageCan {
                        addPerform()
                    }
                }
            }.store(in: &cancellables)
        
    }
    
    
}
// MARK: - 새로운 리스트로 데이터 세팅
private extension MainVM {
    func viewOnTask() {
        if output.showDatas.isEmpty {
            Task {
                await self.updatePerformanceList()
            }
        }
    }
    func seleectDateOrType() {
        Task {
            await self.updatePerformanceList()
        }
    }
    func addPerform() {
        Task {
            await self.addperformanceList()
        }
    }
    
}
private extension MainVM {
    // MARK: - 공연 데이터 초기화 시켜주는 함수
    func addperformanceList() async {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateString = dateFormatter.string(from: output.setDate)
        
        do {
            let data = try await NetworkManager.shared.requestPerformance(date: dateString, genreType: output.showType, title: output.searchText, page: String(page)).map {$0.transformperformanceModel()}
            DispatchQueue.main.async {
                self.page += 1
                if data.isEmpty {
                    self.isPageCan = false
                } else {
                    self.output.showDatas.append(contentsOf: data)
                }
            }
        } catch {
            self.isPageCan = false
        }
    }
    // MARK: - 날짜 변경같이 데이터들의 값을 아예 갈아엎는 경우
    func updatePerformanceList() async {
        let dateFormatter = DateFormatter()
        let selectDateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        selectDateFormatter.dateFormat = "yyyy년 M월 d일"
        let dateString = dateFormatter.string(from: output.setDate)
        let selecetDateStr = selectDateFormatter.string(from: output.setDate)
        DispatchQueue.main.async {
            self.output.selectDate = selecetDateStr
        }
        do {
            // MARK: - page 변경해서 페이지네이션 기능 구현해줘야됨!
            let data = try await NetworkManager.shared.requestPerformance(date: dateString, genreType: output.showType, title: output.searchText, page: "1").map {$0.transformperformanceModel()}
            DispatchQueue.main.async {
                self.page = 2
                self.isPageCan = true
                self.output.showDatas = data
                
                if !self.output.showDatas.isEmpty {
                    self.checkDetailPerformancData(id: self.output.showDatas[0].id)
                }
            }
            
        } catch {
            print("오류 에러처리해주자!!!")
        }
        
    }
    // MARK: - 디테일 데이터 유무 판별
    func checkDetailPerformancData(id: UUID) {
        let model = self.output.showDatas.filter { $0.id == id}.first
        guard let model else { return }
        if model.emptyDetailCheck { //디테일 부분이 빈경우
            Task {
                await self.updateDetailPerformanc(model)
            }
        } else { //이미 디테일 데이터를 가진 경우
            self.output.selectCellId = model.id
            self.output.selectPost = model.detail
        }
    }
    // MARK: - 디테일 데이터 없을 경우 네트워킹하기
    func updateDetailPerformanc(_ model: PerformanceModel) async {
        do {
            let data = try await NetworkManager.shared.requestDetailPerformance(performanceId: model.simple.playId).transformDetailModel()
            if let index = self.output.showDatas.firstIndex(where: {$0.id == model.id}) {
                DispatchQueue.main.async {
                    self.output.showDatas[index].detail = data
                    self.output.selectPost = data
                    self.output.showDatas[index].emptyDetailCheck = false
                    self.output.selectCellId = model.id
                }
            }
        } catch {
            print("디테일 데이터 가져오기 에러처리 해주기")
        }
    }
    
}
