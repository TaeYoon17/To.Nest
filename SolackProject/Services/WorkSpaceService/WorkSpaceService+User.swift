//
//  WorkSpaceService+User.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
extension WorkSpaceService{
    func checkMembers() {
    }
    func inviteUser(emailText:String){
        Task{
            do{
                let res = try await NM.shared.inviteWS(mainWS.id, email: emailText)
                event.onNext(.invited(res))
            }catch{
                guard authValidCheck(error: error) else {
                    AppManager.shared.userAccessable.onNext(false)
                    return
                }
                if let ws = error as? WSFailed{
                    event.onNext(.failed(ws))
                }
            }
        }
    }
}
