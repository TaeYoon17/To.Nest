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

final class WSMainVM: ObservableObject{
    @MainActor @DefaultsState(\.mainWS) var mainWS
    // View - ViewController 간 통신
    var createWorkSpaceTapped: PassthroughSubject<(),Never> = .init()
    var changeWorkSpaceManagerTapped:PassthroughSubject<(),Never> = .init()
    var editWorkSpaceManagerTapped: PassthroughSubject<(),Never> = .init()
    var closeAction: PassthroughSubject<(),Never> = .init()
    
    // View 데이터
    @Published var list:[WorkSpaceListItem] = []
    @Published var selectedWorkSpaceID = 0
    @Published var selectedIdx = 0
    @Published var toastType: WSToastType? = nil
    @Published var isReceivedWorkSpaceList:Bool = false
    @DefaultsState(\.userID) var userID
    var counter = TaskCounter()
    var provider: ServiceProviderProtocol
    var disposeBag = DisposeBag()
    var subscription = Set<AnyCancellable>()
    
    init(_ provider: ServiceProviderProtocol){
        self.provider = provider
        binding()
    }
    @MainActor func updateMainWS(idx: Int){
        self.tempToastUp()
        self.list[selectedIdx].isSelected = false
        selectedIdx = idx
        self.list[selectedIdx].isSelected = true
        // 메인 화면 워크스페이스도 바꾼다.
        provider.wsService.setHomeWS(wsID: list[idx].id)
        self.mainWS.updateMainWSID(id: list[idx].id, myManaging: list[idx].isMyManaging)
        // 사이드바 dismiss처리도 해야한다.
        closeAction.send(())
    }
}

//MARK: -- 워크스페이스 API 통신 로직
extension WSMainVM{
    func getList(){
        provider.wsService.checkAllWS()
    }
    @MainActor func deleteWorkSpace(){
        provider.wsService.delete(workspaceID:self.mainWS.id)
    }
    @MainActor func exitWorkSpace(){
        provider.wsService.exit(workspaceID: mainWS.id)
    }
}
