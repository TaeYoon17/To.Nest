//
//  DBMErrorPolicy.swift
//  SolackProject
//
//  Created by 김태윤 on 1/25/24.
//

import Foundation

// MARK: -- 레포지토리 관련 에러들
enum RepositoryError: Error{
    case TableNotFound
}
