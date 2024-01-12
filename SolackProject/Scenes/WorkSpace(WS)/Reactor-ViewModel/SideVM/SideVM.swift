//
//  SideVM.swift
//  SolackProject
//
//  Created by 김태윤 on 1/12/24.
//

import Foundation
import Combine
import RxSwift
import UIKit

final class SideVM: ObservableObject{
    // View - ViewController 간 통신
    @MainActor @Published var isOpen = false
    var createWorkSpaceTapped: PassthroughSubject<(),Never> = .init()
    var closeAction: PassthroughSubject<(),Never> = .init()
    
    //ViewController 데이터
    var toastPublish: PublishSubject<WSToastType?> = .init()
    
    // View 데이터
    @MainActor @Published var list:[WorkSpaceListItem] = []
    @Published var selectedWorkSpaceID = 0
    
    @DefaultsState(\.userID) var userID
    var counter = TaskCounter()
    var underList:[WSResponse] = []
    var provider: ServiceProviderProtocol
    var disposeBag = DisposeBag()
    
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
        binding()
    }
}

//MARK: -- 워크스페이스 API 통신 로직
extension SideVM{
    func getList(){
        provider.wsService.checkAllWS()
    }
    func deleteWorkSpace(){
        provider.wsService.delete(workspaceID:"\(selectedWorkSpaceID)")
    }
}
