//
//  ErrorTests.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/12/1.
//

import Testing
import Foundation
@testable import AsyncMoya

@Suite("Error Tests")
struct ErrorTests {
    var response: Response! = Response(statusCode: 200, data: Data(), response: nil)
    var underlyingError: NSError! = NSError(domain: "UnderlyingDomain", code: 200, userInfo: ["data": "some data"])
    
    @Test("response computed variable should handle ImageMapping error")
    func test1() {
        let error = MoyaError.imageMapping(response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should handle JSONMapping error")
    func test2() {
        let error = MoyaError.jsonMapping(response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should handle StringMapping error")
    func test3() {
        let error = MoyaError.stringMapping(response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should handle Object Mapping error")
    func test4() {
        let error = MoyaError.objectMapping(underlyingError, response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should not handle EncodableMapping error")
    func test5() {
        let error = MoyaError.encodableMapping(underlyingError)
        #expect(error.response == nil)
    }
    
    @Test("response computed variable should handle StatusCode error")
    func test6() {
        let error = MoyaError.statusCode(response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should handle Underlying error")
    func test7() {
        let error = MoyaError.underlying(underlyingError, response)
        #expect(error.response == response)
    }
    
    @Test("response computed variable should not handle RequestMapping error")
    func test8() {
        let error = MoyaError.requestMapping("http://www.example.com")
        #expect(error.response == nil)
    }
    
    @Test("response computed variable should not handle ParameterEncoding error")
    func test9() {
        let error = MoyaError.parameterEncoding(underlyingError)
        #expect(error.response == nil)
    }
    
    @Test("underlyingError computed variable should not handle ImageMapping error")
    func test10() {
        let error = MoyaError.imageMapping(response)
        #expect(error.underlyingError == nil)
    }
    
    @Test("underlyingError computed variable should not handle JSONMapping error")
    func test11() {
        let error = MoyaError.jsonMapping(response)
        #expect(error.underlyingError == nil)
    }
    
    @Test("underlyingError computed variable should not handle StringMapping error")
    func test12() {
        let error = MoyaError.stringMapping(response)
        #expect(error.underlyingError == nil)
    }
    
    @Test("underlyingError computed variable should handle ObjectMapping error")
    func test13() {
        let error = MoyaError.objectMapping(underlyingError, response)
        #expect(error.underlyingError as NSError? == underlyingError)
    }
    
    @Test("underlyingError computed variable should handle EncodableMapping error")
    func test14() {
        let error = MoyaError.encodableMapping(underlyingError)
        #expect(error.underlyingError as NSError? == underlyingError)
    }
    
    @Test("underlyingError computed variable should not handle StatusCode error")
    func test15() {
        let error = MoyaError.statusCode(response)
        #expect(error.underlyingError == nil)
    }
    
    @Test("underlyingError computed variable should handle Underlying error")
    func test16() {
        let error = MoyaError.underlying(underlyingError, response)
        #expect(error.underlyingError as NSError? == underlyingError)
    }
    
    @Test("underlyingError computed variable should not handle RequestMapping error")
    func test17() {
        let error = MoyaError.requestMapping("http://www.example.com")
        #expect(error.underlyingError as NSError? == nil)
    }
    
    @Test("underlyingError computed variable should handle ParameterEncoding error")
    func test18() {
        let error = MoyaError.parameterEncoding(underlyingError)
        #expect(error.underlyingError as NSError? == underlyingError)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and no underlying error for ImageMapping error")
    func test19() {
        let error = MoyaError.imageMapping(response)
        let userInfo = (error as NSError).userInfo
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == nil)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and no underlying error for JSONMapping error")
    func test20() {
        let error = MoyaError.jsonMapping(response)
        let userInfo = (error as NSError).userInfo
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == nil)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and no underlying error for StringMapping error")
    func test21() {
        let error = MoyaError.stringMapping(response)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == nil)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and underlying error for ObjectMapping error")
    func test22() {
        let error = MoyaError.objectMapping(underlyingError, response)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == underlyingError)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and underlying error for EncodableMapping error")
    func test23() {
        let error = MoyaError.encodableMapping(underlyingError)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == underlyingError)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and no underlying error for StatusCode error")
    func test24() {
        let error = MoyaError.statusCode(response)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == nil)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and underlying error for Underlying error")
    func test25() {
        let error = MoyaError.underlying(underlyingError, nil)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == underlyingError)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and no underlying error for RequestMapping error")
    func test26() {
        let error = MoyaError.requestMapping("http://www.example.com")
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == nil)
    }
    
    @Test("bridged userInfo dictionary should have a localized description and underlying error for ParameterEncoding error")
    func test27() {
        let error = MoyaError.parameterEncoding(underlyingError)
        let userInfo = (error as NSError).userInfo
        
        #expect(userInfo[NSLocalizedDescriptionKey] as? String == error.errorDescription)
        #expect(userInfo[NSUnderlyingErrorKey] as? NSError == underlyingError)
    }
    
    @Test("mapping a result with empty data fails on mapJSON with default parameter")
    func test28() {
        let response = Response(statusCode: 200, data: Data())
        var mapJSONFailed = false
        do {
            _ = try response.mapJSON()
        } catch {
            mapJSONFailed = true
        }
        #expect(mapJSONFailed)
    }
    
    @Test("mapping a result with empty data returns default non-nil value on mapJSON with overridden parameter")
    func test29() {
        let response = Response(statusCode: 200, data: Data())
        var succeeded = true
        do {
            _ = try response.mapJSON(failsOnEmptyData: false)
        } catch {
            succeeded = false
        }
        #expect(succeeded)
    }
    
    @Test("responses should return the errors where appropriate should return the underlying error in spite of having a response and data")
    func test30() {
        let underlyingError = NSError(domain: "", code: 0, userInfo: nil)
        let request = NSURLRequest() as URLRequest
        let response = HTTPURLResponse()
        let data = Data()
        let result = convertResponseToResult(response, request: request, data: data, error: underlyingError)
        switch result {
        case let .failure(error):
            switch error {
            case .underlying(let error, _):
                #expect(error as NSError == underlyingError)
            default:
                Testing.Issue.record("expected to get underlying error")
            }
        case .success:
            Testing.Issue.record("expected to be failing result")
        }
    }
}
