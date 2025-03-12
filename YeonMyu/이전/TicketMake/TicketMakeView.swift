//
//  TicketMakeView.swift
//  musicalRecordProject
//
//  Created by 박성민 on 9/28/24.
//

import SwiftUI
import Kingfisher
import RealmSwift
struct TicketMakeView: View {
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    private let inputBackColor = Color.grayBackground
    private let inputHeight: CGFloat = 40
    private let itemSpace: CGFloat = 20
    private let colums = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    var data: DetailPerformance
    var date: String
    @ObservedObject var vm: TicketMakeVM
    @Environment(\.presentationMode) var presentationMode
    init(vm: TicketMakeVM, data: DetailPerformance, date: String) {
        self.vm = vm
        self.data = data
        self.date = date
    }
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                postView()
                titleView()
                Spacer()
                    .frame(height: 20)
                inputView()
            }
            .frame(width: width)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("티켓 만들기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // Action
                    if !vm.output.data.ticekPrice.isEmpty && Int(vm.output.data.ticekPrice) != nil {
                        vm.input.saveButtonTap.send(())
                    }
                } label: {
                    Text("저장")
                        .asForeground(vm.output.data.ticekPrice.isEmpty || Int(vm.output.data.ticekPrice) == nil ? .asPlaceholder : .asFont)
                }
            }
        }
        .onAppear {
            self.vm.input.dataSet.send((data, date))
        }
        .alert(isPresented: $vm.output.saveCompletion) {
            Alert(
                title: Text("저장완료"),
                message: Text(""),
                dismissButton: .default(Text("확인")) {
                    // 확인 버튼을 누르면 이전 뷰로 돌아가게 함
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

//#Preview {
//    TicketMakeView()
//}

// MARK: - 상단 버튼 부분
private extension TicketMakeView {
    func postView() -> some View {
        VStack(alignment: .center) {
            KFImage(URL(string: vm.output.data.image))
                .placeholder { //플레이스 홀더 설정
                    Image.postPlaceholder
                        .resizable()
                }.retry(maxCount: 3, interval: .seconds(5)) //재시도
                .resizable()
                .onSuccess {
                    let imageData = $0.data()
                    if let imageData {
                        self.vm.output.imageData = imageData
                    }
                    
                }
                .frame(width: width * 0.4, height: width * 0.4 * 1.5)
                .padding(.top, 30)
                .padding(.trailing)
            
            
            if vm.output.data.state == .completion {
                RatingView(rating: $vm.output.data.rating)
                    .frame(width: width * 0.1, height: 20)
                    .padding(.top, 10)
            }
        }
        
    }
    // MARK: - 배우 선택 부분
    func inputView() -> some View {
        VStack(alignment: .leading) {
            Text("캐스팅")
                .font(.boldFont16)
                .padding(.leading, 5)
            LazyVGrid(columns: colums) {
                ForEach(vm.output.data.actors, id: \.self) { actor in
                    RoundedRectangle(cornerRadius: 15)
                        .fill(actor.isSelected ? Color.asMainColor : inputBackColor)
                        .frame(height: inputHeight)
                        .frame(minWidth: 40, maxWidth: 90)
                        .overlay {
                            Text(actor.name)
                        }
                        .onTapGesture {
                            vm.input.selecetActor.send(actor.id)
                        }
                }
                
            }
            Spacer()
                .frame(height: itemSpace)
            Text("티켓가격")
                .font(.boldFont16)
                .padding(.leading, 5)
            RoundedRectangle(cornerRadius: 15)
                .fill(inputBackColor)
                .frame(height: inputHeight)
                .overlay {
                    // MARK: - 금액입력시 ,랑 원 나오게 구현나중에 해보자...
                    TextField("금액을 입력해주세요.", text: $vm.output.data.ticekPrice)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                }
            Spacer()
                .frame(height: itemSpace)
            if vm.output.data.state == .completion {
                Text("후기")
                    .font(.boldFont16)
                    .padding(.leading, 5)
                TextEditor(text: $vm.output.data.review)
                    .customStyleEditor(placeholder: "후기를 작성해주세요.", userInput: $vm.output.data.review)
                    .frame(height: 200)
                
                Spacer()
                    .frame(height: itemSpace)
            }
            
            
            Text("관람일자")
                .font(.boldFont16)
                .padding(.leading, 5)
            RoundedRectangle(cornerRadius: 15)
                .fill(inputBackColor)
                .frame(height: inputHeight)
                .overlay {
                    Text(vm.output.data.date)
                }
            Spacer()
                .frame(height: itemSpace)
            Text("공연장소")
                .font(.boldFont16)
                .padding(.leading, 5)
            RoundedRectangle(cornerRadius: 15)
                .fill(inputBackColor)
                .frame(height: inputHeight)
                .overlay {
                    Text(vm.output.data.place)
                }
            
        }
        .padding(.horizontal)
        .frame(width: width, alignment: .leading)
        
    }
    func titleView() -> some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.asMainColor)
                .frame(width: 50, height: 30)
                .overlay {
                    Text(vm.output.data.state.title)
                        .font(.boldFont14)
                        .asForeground(Color.white)
                }
            Text(vm.output.data.title)
                .font(.boldFont17)
                .asForeground(.asFont)
        }
        .frame(width: width, alignment: .leading)
        .padding(.leading, 30)
        
        
    }
    //    func ButtonView(name: String) -> some View {
    //        Button {
    //            // Action
    //            isSelected.toggle()
    //        } label: {
    //            Text("Click Me")
    //                .font(.title3)
    //                .padding()
    //                .frame(maxWidth: .infinity)
    //                .background(isSelected ? Color.purple : Color.white) // 선택되면 보라색, 그렇지 않으면 흰색
    //                .cornerRadius(20)
    //                .overlay(
    //                    Capsule() // 캡슐 모양
    //                        .stroke(isSelected ? Color.purple : Color.gray, lineWidth: 2)
    //                )
    //                .foregroundColor(isSelected ? .white : .black) // 글자색도 변경
    //        }
    //    }
}
