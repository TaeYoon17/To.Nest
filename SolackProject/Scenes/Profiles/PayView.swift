//
//  PayView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import SwiftUI
enum PayAmount:Int, CaseIterable{
    case won100 = 10
    case won500 = 50
    case won1000 = 100
}
struct PayView: View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileVM: MyProfileReactor
    @ObservedObject var vm: PayVM
    init(provider:ServiceProviderProtocol!) {
        self._vm = .init(initialValue: PayVM(provider: provider))
    }
    var body: some View{
        List{
            Section{
                HStack{
                    (Text("🌱 현재 보유한 코인") + Text(" 330개").foregroundColor(.accentColor)).font(FontType.bodyBold.font)
                    Spacer()
                    Text("코인이란?").foregroundStyle(.secondary).font(FontType.caption.font)
                }
            }
            Section {
                ForEach(vm.payAmountList){ payAmount in
                    HStack(content: {
                        Text("🌱 \(payAmount.item)").foregroundStyle(.text).font(FontType.bodyBold.font)
                        Spacer()
                        Button(action: {
                            print("결제 클릭!!")
                        }, label: {
                            Text("₩\(payAmount.amount)")
                                .font(FontType.title2.font)
                                .foregroundStyle(.white)
                                .padding(.horizontal,12)
                                .padding(.vertical,4)
                                .background(.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }).buttonStyle(BorderlessButtonStyle()) // 리스트 내부에 버튼을 추가할 경우 넣어야한다
                    })
                    .background(Color.white)
                    .listRowSeparator(.hidden)
                }
            }
        }
        .listRowBackground(Color.white)
        .scrollContentBackground(.hidden)
        .background(.gray2)
        .navigationTitle("코인샵")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "chevron.left").foregroundStyle(.text).font(.system(size: 17,weight: .bold))
                })
            }
        })
    }
}
