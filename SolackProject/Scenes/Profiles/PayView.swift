//
//  PayView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/19/24.
//

import SwiftUI
import iamport_ios
enum PayAmount:Int, CaseIterable{
    case won100 = 10
    case won500 = 50
    case won1000 = 100
}
struct PayView: View{
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileVM: MyProfileReactor
    @StateObject var vm: PayVM
    @State var paymentView: PaymentView = PaymentView()
    @State private var toastType:ToastType? = nil
    init(provider:ServiceProviderProtocol!) {
        self._vm = .init(wrappedValue: PayVM(provider: provider))
    }
    var body: some View{
        ZStack{
            listView
            if vm.isPayment {
                paymentView.frame(width: 0, height: 0).opacity(0)
                    .onBackgroundDisappear({
                        vm.action(type: .closePay)
                    }).environmentObject(vm)
            }
        }
        .toast(type: $toastType, alignment: .bottom, position: .zero)
        .onChange(of: vm.toastType, perform: { value in
            toastType = value
        })
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
extension PayView{
    @ViewBuilder var listView: some View{
        List{
            Section{
                HStack{
                    (Text("🌱 현재 보유한 코인") + Text(" \(vm.nowPossessionCoin)개").foregroundColor(.accentColor)).font(FontType.bodyBold.font)
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
                            vm.action(type: .requirePay(payAmount: payAmount))
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
    }
}
