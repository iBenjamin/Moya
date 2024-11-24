//
//  AccessTokenPlugin.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/24.
//

import Foundation
import Testing
import AsyncMoya

@Suite("AccessTokenPluginTests")
struct AccessTokenPluginTests {
    struct TestTarget: TargetType, AccessTokenAuthorizable {
        let baseURL = URL(string: "http://www.api.com/")!
        let path = ""
        let method = HTTPMethod.get
        let task = Task.requestPlain
        let sampleData = Data()
        let headers: [String: String]? = nil
        let authorizationType: AuthorizationType?
    }
    
    static let token = "eyeAm.AJsoN.weBTOKen"
    var plugin: AccessTokenPlugin = {
        .init { _ in
            Self.token
        }
    }()
    
    @Test("doesn't add an authorization header to TargetTypes by default")
    func test1() {
        let target = GitHub.zen
        let request = URLRequest(url: target.baseURL)
        let preparedRequest = self.plugin.prepare(request, target: target)
        #expect(preparedRequest.allHTTPHeaderFields == nil)
    }
    
    @Test("doesn't add an authorization header to AccessTokenAuthorizables when AuthorizationType is nil")
    func test2() {
        let preparedRequest = self.createPreparedRequest(for: nil)
        #expect(preparedRequest.allHTTPHeaderFields == nil)
    }
    
    @Test("adds a basic authorization header to AccessTokenAuthorizables when AuthorizationType is .basic")
    func test3() {
        let authorizationType: AuthorizationType = .basic
        let preparedRequest = self.createPreparedRequest(for: authorizationType)
        
        let authValue = authorizationType.value
        #expect(preparedRequest.allHTTPHeaderFields == ["Authorization": "\(authValue) \(Self.token)"])
    }
    
    @Test("adds a bearer authorization header to AccessTokenAuthorizables when AuthorizationType is .bearer")
    func test4() {
        let authorizationType: AuthorizationType = .bearer
        let preparedRequest = self.createPreparedRequest(for: authorizationType)
        
        let authValue = authorizationType.value
        #expect(preparedRequest.allHTTPHeaderFields == ["Authorization": "\(authValue) \(Self.token)"])
    }
    
    @Test("adds a custom authorization header to AccessTokenAuthorizables when AuthorizationType is .custom")
    func test5() {
        let authorizationType: AuthorizationType = .custom("CustomAuthorizationHeader")
        let preparedRequest = self.createPreparedRequest(for: authorizationType)

        let authValue = authorizationType.value
        #expect(preparedRequest.allHTTPHeaderFields == ["Authorization": "\(authValue) \(Self.token)"])
    }
    
    private func createPreparedRequest(for type: AuthorizationType?) -> URLRequest {
        let target = TestTarget(authorizationType: type)
        let request = URLRequest(url: target.baseURL)
        
        return plugin.prepare(request, target: target)
    }
}
