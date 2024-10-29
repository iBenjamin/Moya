//
//  File.swift
//  Moya
//
//  Created by Benjamin Wong on 2024/10/29.
//

import Foundation

public extension MoyaProvider {
  class MoyaConcurrency {
    private let provider: MoyaProvider

    init(provider: MoyaProvider) {
      self.provider = provider
    }

    func request(_ target: Target) async throws -> Response {
      return try await withCheckedThrowingContinuation { continuation in
        provider.request(target) { result in
          switch result {
          case .success(let resposne):
            continuation.resume(returning: resposne)
          case .failure(let error):
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }

  var async: MoyaConcurrency {
    MoyaConcurrency(provider: self)
  }
}

extension TargetType {
  var asMultiTarget: MultiTarget {
    MultiTarget(self)
  }
}
