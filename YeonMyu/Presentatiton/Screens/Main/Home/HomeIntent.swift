//
//  HomeIntent.swift
//  musicalRecordProject
//
//  Created by 박성민 on 2/23/25.
//

import Foundation

protocol HomeIntentProtocol {
    func onAppear(city: CityCode, prfCate: PrfCate) //처음 뷰 뜰 때
    func refreshAll() //새로고침 시
    func postTapped(id: String?) // 포스터 클릭 시
    func userInfoTapped(info: UserInfo?) //유저 공연 정보 기록 클릭 시
    func playCategoryTapped(_ index: Int, city: CityCode, prfCate: PrfCate) //공연 종류 선택 시
    func areaTapped(area: CityCode, prfCate: PrfCate) //지역 선택 시
    func insertHeaderData(_ data: MainHeaderPlayModel) //
}

final class HomeIntent {
    private weak var state: HomeStateActionProtocol?
    init(state: HomeStateActionProtocol?) {
        self.state = state
    }
}

extension HomeIntent: HomeIntentProtocol {
    //처음 뷰 뜰 때
    func onAppear(city: CityCode, prfCate: PrfCate) {
        Task {
            do {
                let headerPosts = try await self.getHeaderPostData()
                state?.getHeaderPosts(headerPosts)
                
                let userAreaInfoPosts = try await getUserAreaPlayList(area: city, PrfCate: prfCate, page: 1)
                state?.getUserAreaInfoPosts(userAreaInfoPosts)
                
                let simplePosts = try await getSimpleRandomPostData()
                state?.getRandomPrfs(simplePosts)
                
                state?.getContentState(.content)
            
            } catch {
                print("뷰가 처음 뜰때 오류 발생")
            }
        }
    }
    //새로고침 시
    func refreshAll() {
        state?.getContentState(.loading)
        Task {
            do {
                let headerPosts = try await self.getHeaderPostData()
                state?.getHeaderPosts(headerPosts)
                state?.getContentState(.content)
            
            } catch {
                print("새로 고침 중 오류 발생")
            }
        }
    }
    // 포스터 클릭 시
    func postTapped(id: String?) {
        state?.getPostId(id)
    }
    //유저 공연 정보 기록 클릭 시
    func userInfoTapped(info: UserInfo?) {
        state?.getSelectedUserInfo(info)
    }
    //공연 종류 선택 시
    func playCategoryTapped(_ index: Int, city: CityCode, prfCate: PrfCate) {
        state?.getPlayCategoryIndex(index)
        Task {
            do {
                let userAreaInfoPosts = try await getUserAreaPlayList(area: city, PrfCate: prfCate, page: 1)
                state?.getUserAreaInfoPosts(userAreaInfoPosts)
            } catch {
                print("공연 종류 선택 중 오류 발생")
            }
        }
    }
    //지역 선택 시
    func areaTapped(area: CityCode, prfCate: PrfCate) {
        state?.getCity(area)
        Task {
            do {
                let userAreaInfoPosts = try await getUserAreaPlayList(area: area, PrfCate: prfCate, page: 1)
                state?.getUserAreaInfoPosts(userAreaInfoPosts)
            } catch {
                print("공연 종류 선택 중 오류 발생")
            }
        }
        
    }
    
    func insertHeaderData(_ data: MainHeaderPlayModel) {
        state?.insertHeaderData(data)
    }
   
}

// MARK: - 랜덤 포스터 조회 부분
private extension HomeIntent {
    func getHeaderPostData() async throws -> [MainHeaderPlayModel] {
        var randomData = [nowOpenPrf, getNowYearAwardPrf, getLastYearAwardPrf, getTop1WithArea]
        
        //추가 랜덤 데이터 넣어주슈!
        
        randomData.shuffle() //랜덤 뽑기 진행
        while randomData.count < 4 { //데이터가 3개가 될때까지 삭제 진행
            randomData.removeLast()
        }
        
        let resultArray = await withTaskGroup(of: MainHeaderPlayModel?.self) { group in //병렬로 비동기 처리 진행
            var postData: [MainHeaderPlayModel?] = []
            
            for request in randomData { //비동기 처리 진행
                group.addTask {
                    let data = try? await request()
                    return data
                }
            }
            
            for await data in group { //완료된 비동기 처리 담기
                if let data {
                    postData.append(data)
                }
            }
            return postData
        }
        return resultArray.compactMap { $0 }
    }
    
    //곧 상영 예정인 공연
    func nowOpenPrf() async throws ->  MainHeaderPlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: 2)
        let data = try await NetworkManager.shared.requestPerformance(date: date, cateCode: "", area: "", title: "", page: nil, openrun: nil, prfstate: "?")
        guard let post = data.first else { return nil}
        let result = MainHeaderPlayModel(mainTitle: "곧 상영 예정인 공연", subTitle: "타이틀 회의하자~", postURL: post.poster, postID: post.mt20id)
        return result
    }
    //현재 날짜 기준 상받은 공연
    func getNowYearAwardPrf() async throws ->  MainHeaderPlayModel? {
        let nowDate = String.getDateRelativeToToday(daysOffset: 0)
        let beforDate = String.getDateRelativeToToday(daysOffset: -90)
        let data = try await NetworkManager.shared.requestAwad(startDate: beforDate, endDate: nowDate, cateCode: nil, area: nil, page: nil)
        guard let resultAward = data.first else { return nil }
        //resultAward.awards // 수상 내역
        let result = MainHeaderPlayModel(mainTitle: "현재 날짜 기준 90일 이전으로\n상받은 공연~", subTitle: "타이틀 정하자~", postURL: resultAward.poster, postID: resultAward.mt20id)
        return result
    }
    //현재 날짜 기준 작년 상받은 공연 정보
    func getLastYearAwardPrf() async throws ->  MainHeaderPlayModel? {
        let lastDate = String.getLastYearDatesToyyyyMMdd()
        let data = try await NetworkManager.shared.requestAwad(startDate: lastDate, endDate: lastDate, cateCode: nil, area: nil, page: nil)
        guard let resultAward = data.first else { return nil }
        //resultAward.awards // 수상 내역
        let postData = try await NetworkManager.shared.requestDetailPerformance(performanceId: resultAward.mt20id)
        let result = MainHeaderPlayModel(mainTitle: "작년 이날 날짜 기준\n상받은 공연~", subTitle: "타이틀 정하자~", postURL: postData.poster, postID: postData.mt20id)
        return result
    }
    //사용자 지정 지역의 실시간 1위 판매 공연
    func getTop1WithArea() async throws -> MainHeaderPlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: -30)
        let ddate = String.getDateRelativeToToday(daysOffset: 0)
        let area = "11" //임시 지역 서울!
        let data = try await NetworkManager.shared.requestBoxOffice(startDate: date, endDate: ddate, cateCode: "AAAA", area: area) //area 수정해주기
        guard let post = data.first else { return nil }
        let result = MainHeaderPlayModel(mainTitle: "사용자 지역 기준 실시간 1위\n판매 공연!!!", subTitle: "타이틀 정하슈", postURL: post.poster, postID: post.mt20id)
        return result
    }
    
}
// MARK: - 지역별 랜덤 공연 정보 부분
private extension HomeIntent {
    //지역별 공연 조회
    func getUserAreaPlayList(area: CityCode, PrfCate: PrfCate, page: Int?) async throws -> [SimplePostModel] {
        var data: [SimplePostModel] = []
        for cate in PrfCate.code {
            let result = try await NetworkManager.shared.requestPerformance(date: String.getDateRelativeToToday(daysOffset: 0), cateCode: cate, area: area.code, title: "", page: page, openrun: nil, prfstate: nil)
            data.append(contentsOf: result.map{$0.transformSimplePostModel()})
        }
        data.shuffle()
        return data.filter { $0.getPostString() != "" }
    }
    
    //최종 랜덤 포스터 데이터
    func getSimpleRandomPostData() async throws -> RandomSimplePlayModel? {
        let randomFunctions: [() async throws -> RandomSimplePlayModel?] = [nowOpenPrfs]
        
        guard let randomFunction = randomFunctions.randomElement() else {
            return nil
        }
        
        return try await randomFunction()
    }
    
    
    
    //곧 상영 예정인 공연
    func nowOpenPrfs() async throws ->  RandomSimplePlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: 2)
        let data = try await NetworkManager.shared.requestPerformance(date: date, cateCode: "", area: "", title: "", page: nil, openrun: nil, prfstate: "?")
//        guard let post = data.first else { return nil}
//        let result = MainHeaderPlayModel(mainTitle: "곧 상영 예정인 공연", subTitle: "타이틀 회의하자~", postURL: post.poster, postID: post.mt20id)
        let result = RandomSimplePlayModel(mainTitle: "곧 상영 예정", subTitle: "서브타이틀입니돠~", simplePlayData: data.map{ $0.transformSimplePostModel() }.filter { $0.getPostString() != "" })
        return result
    }
    
    //사용자 지정 지역의 실시간 인기 순위
    func getTop10WithArea() async throws -> RandomSimplePlayModel? {
        let date = String.getDateRelativeToToday(daysOffset: -30)
        let ddate = String.getDateRelativeToToday(daysOffset: 0)
        let area = "11" //임시 지역 서울!
        let data = try await NetworkManager.shared.requestBoxOffice(startDate: date, endDate: ddate, cateCode: "AAAA", area: area) //area 수정해주기
        print(data)
        let result = RandomSimplePlayModel(mainTitle: "사용자 위치에 실시간 인기 공연들", subTitle: "서브타이틀 임돠", simplePlayData: data.map { $0.transformSimplePostModel() })
        return result
    }
    
}

