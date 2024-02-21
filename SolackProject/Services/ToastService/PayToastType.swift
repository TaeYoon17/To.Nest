//
//  PayToastType.swift
//  SolackProject
//
//  Created by 김태윤 on 2/20/24.
//

import UIKit

enum PayToastType: ToastType{
    case success
    case validFailure,payFailure
    var contents: String{
        switch self{
        case .success: "코인 결제가 성공적으로 완료되었어요"
        case .validFailure:"코인 결제 인증이 실패되었어요.\n자정에 환불을 진행합니다."
        case .payFailure: "결제가 취소되었어요. 다시 시도해주세요"
        }
    }
    
    var getColor: UIColor{
        switch self{
        case .success: UIColor.accent
        case .validFailure,.payFailure:UIColor.error
        }
    }
}
