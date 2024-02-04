//
//  StringValidation.swift
//  SolackProject
//
//  Created by 김태윤 on 2/4/24.
//

import Foundation
//MARK: -- Mutation 변경 확인 사항
 extension String{
         func validationEmail()->Bool{
             let email = ".*\\.(com|co\\.kr|net).*"
             let emailRegex = ".*@.*"
             do{
                 let val = try Regex(emailRegex)
                 let one = try Regex(email)
                 guard self.contains(one) else {return false}
                 return self.contains(val)
             }catch{
                 return false
             }
         }
    func validationNick()->Bool{
        0 < self.count && self.count <= 30
    }
     func validataionPhone()->Bool{
        if self.isEmpty {return true}
        guard self.prefix(2) == "01" else{ return false}
        let wow = self.replacingOccurrences(of: "-", with: "").count
        if wow < 10 || wow > 11 {return false}
        return true
    }
    func validationPW()->Bool{
        guard self.count >= 8 else {
            return false
        }
        let pwRegex =  "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[^a-zA-Z\\d]).+$"
        do{
            let val = try Regex(pwRegex)
            return self.contains(val)
        }catch{
            return false
        }
    }
    
}
