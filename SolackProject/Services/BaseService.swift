//
//  BaseService.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import Foundation
import RxSwift
class BaseService {
  weak private(set) var provider: ServiceProviderProtocol!

  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
}
