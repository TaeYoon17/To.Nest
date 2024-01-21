//
//  WSService+HomeFeatures.swift
//  SolackProject
//
//  Created by 김태윤 on 1/22/24.
//

import Foundation
import RxSwift
extension WSService{
    func initHome(){
        Task{
            do{
                let allWS = try await NM.shared.checkAllWS()
                if let id = allWS.first?.workspaceID{
                    let homeWS = try await NM.shared.checkWS(wsID: id)
                    mainWS = id
                    event.onNext(.homeWS(homeWS))
                }else{
                    event.onNext(.homeWS(nil))
                }
            }catch{
                print("워크스페이스 사이드 에러!!")
                guard authValidCheck(error: error) else{
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                print("걸리기 실패",error)
            }
        }
    }
    func setHomeWS(wsID: Int) {
        Task{
            let newHomeWS = try await NM.shared.checkWS(wsID:wsID)
            mainWS = newHomeWS.ownerID
        }
    }
}
