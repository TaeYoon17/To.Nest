//
//  WorkSpaceService+User.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
extension WorkSpaceService{
    func checkAllMembers() {
        let wsID = mainWS.id
        Task{
            do{
                let res = try await NM.shared.checkWSMembers(wsID)
                event.onNext(.wsAllMembers(res))
            }catch{
                print("checkAllMembers")
            }
        }
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
    func changeAdmin(userID:Int){
        Task{
            let mainWS = self.mainWS.id
            do{
                print("changeAdmin")
                print(self.mainWS,self.userID)
                let res = try await NM.shared.adminChangeWS(wsID: mainWS, userID: userID)
                print("changeAdmin Success \(res)")
                event.onNext(.adminChanged(res))
            }
            catch{
                AppManager.shared.accessErrorHandler(of: WSFailed.self, error) { [weak self] wsFailed in
                    guard let self, let wsFailed else {return}
                    print("changeAdmin Error")
                    event.onNext(.failed(wsFailed))
                }
            }
        }
    }
}
