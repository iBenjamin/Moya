//
//  EndpointTests.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/23.
//

import Foundation
import Testing
import AsyncMoya

@Suite("EndpointTest")
struct EndpointTests {
    private static func simpleGitHubEndpoint() -> Endpoint {
        let target: GitHub = .zen
        let headerFields = ["Title": "Dominar"]
        return Endpoint(url: url(target), sampleResponseClosure: {.networkResponse(200, target.sampleData)}, method: HTTPMethod.get, task: .requestPlain, httpHeaderFields: headerFields)
    }
    
    private var endpoint: Endpoint = Self.simpleGitHubEndpoint()
    
    @Test("returns a new endpoint for adding(newHTTPHeaderFields:)")
    func returnsANewEndpointForAddingNewHeaderFields() async throws {
        let agent = "Zalbinian"
        let newEndpoint = endpoint.adding(newHTTPHeaderFields: ["User-Agent": agent])
        let newEndpointAgent = newEndpoint.httpHeaderFields?["User-Agent"]
        
        // Make sure our closure updated the sample response, as proof that it can modify the Endpoint
        #expect(newEndpointAgent == agent)
        
        // Compare other properties to ensure they've been copied correctly\
        #expect(newEndpoint.url == endpoint.url)
        #expect(newEndpoint.method == endpoint.method)
    }
    
    @Test("returns a nil urlRequest for an invalid URL")
    func returnsANilURLRequestForAnInvalidURL() {
        let badEndpoint = Endpoint(url: "some invalid URL", sampleResponseClosure: { .networkResponse(200, Data()) }, method: .get, task: .requestPlain, httpHeaderFields: nil)
        let urlRequest = try? badEndpoint.urlRequest()
        #expect(urlRequest == nil)
    }
    
    // MARK: - successful converting to urlRequest
    @Test("successful converting to urlRequest when task is .requestPlain, endpoint with no request property changed, didn't update any of the request properties")
    func successfulConvertingToURLRequestWhenTaskIsPlainEndpointWithNoRequestPropertyChanged() throws {
        let newEndpoint = endpoint.replacing(task: .requestPlain)
        let request = try newEndpoint.urlRequest()
        #expect(request.httpBody == nil)
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.allHTTPHeaderFields == endpoint.httpHeaderFields)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("successful converting to urlRequest when task is .uploadFile, endpoint with no request property changed, didn't update any of the request properties")
    func successfulConvertingToURLRequestWhenTaskIsUploadFileEndpointWithNoRequestPropertyChanged() throws {
        let newEndpoint = endpoint.replacing(task: .uploadFile(URL(string: "https://www.google.com")!))
        let request = try newEndpoint.urlRequest()
        #expect(request.httpBody == nil)
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.allHTTPHeaderFields == endpoint.httpHeaderFields)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("successful converting to urlRequest when task is .uploadMultipartFormData, endpoint with no request property changed, didn't update any of the request properties")
    func successfulConvertingToURLRequestWhenTaskIsUploadMultipartFormDataEndpointWithNoRequestPropertyChanged() throws {
        let newEndpoint = endpoint.replacing(task: .uploadMultipartFormData([]))
        let request = try newEndpoint.urlRequest()
        #expect(request.httpBody == nil)
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.allHTTPHeaderFields == endpoint.httpHeaderFields)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("successful converting to urlRequest when task is .downloadDestination, endpoint with no request property changed, didn't update any of the request properties")
    func successfulConvertingToURLRequestWhenTaskIsDownloadDestinationEndpointWithNoRequestPropertyChanged() throws {
        let destination: DownloadDestination = { url, response in
            return (url, [])
        }
        let newEndpoint = endpoint.replacing(task: .downloadDestination(destination))
        let request = try newEndpoint.urlRequest()
        #expect(request.httpBody == nil)
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.allHTTPHeaderFields == endpoint.httpHeaderFields)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("successful converting to urlRequest when task is .requestParameters, endpoint with encoded parameters, updated the request correctly")
    func successfulConvertingToURLRequestWhenTaskIsRequestParametersEndpointWithEncodedParametersUpdatedTheRequestCorrectly() throws {
        let parameters = ["Nemesis": "Harvey"]
        let encoding = JSONEncoding.default
        let endpoint = self.endpoint.replacing(task: .requestParameters(parameters: parameters, encoding: encoding))
        let request = try endpoint.urlRequest()
        let newEndpoint = endpoint.replacing(task: .requestPlain)
        let newRequest = try newEndpoint.urlRequest()
        let newEncodedRequest = try encoding.encode(newRequest, with: parameters)
        #expect(request.httpBody == newEncodedRequest.httpBody)
        #expect(request.url?.absoluteString == newEncodedRequest.url?.absoluteString)
        #expect(request.allHTTPHeaderFields == newEncodedRequest.allHTTPHeaderFields)
        #expect(request.httpMethod == newEncodedRequest.httpMethod)
    }
    
    @Test("successful converting to urlRequest when task is .downloadParameters, endpoint with encoded parameters, updated the request correctly")
    func successfulConvertingToURLRequestWhenTaskIsDownloadParametersEndpointWithEncodedParametersUpdatedTheRequestCorrectly() throws {
        let parameters = ["Nemesis": "Harvey"]
        let encoding = JSONEncoding.default
        let destination: DownloadDestination = { url, response in
            return (destinationURL: url, options: [])
        }
        let endpoint = self.endpoint.replacing(task: .downloadParameters(parameters: parameters, encoding: encoding, destination: destination))
        let request = try endpoint.urlRequest()
        let newEndpoint = endpoint.replacing(task: .requestPlain)
        let newRequest = try newEndpoint.urlRequest()
        let newEncodedRequest = try encoding.encode(newRequest, with: parameters)
        #expect(request.httpBody == newEncodedRequest.httpBody)
        #expect(request.url?.absoluteString == newEncodedRequest.url?.absoluteString)
        #expect(request.allHTTPHeaderFields == newEncodedRequest.allHTTPHeaderFields)
        #expect(request.httpMethod == newEncodedRequest.httpMethod)
    }
    
    @Test("when task is .requestData, updates httpBody and doesn't update any of the other properties")
    func successfulConvertingToURLRequestWhenTaskIsRequestDataUpdatesHttpBodyAndDoesntUpdateAnyOfTheOtherProperties() throws {
        let data = "test data".data(using: .utf8)!
        let endpoint = self.endpoint.replacing(task: .requestData(data))
        let request = try endpoint.urlRequest()
        #expect(request.httpBody == data)
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.allHTTPHeaderFields == endpoint.httpHeaderFields)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("when task is .requestJSONEncodable")
    func taskIsRequestJSONEncodable() throws {
        // updates httpBody
        let issue = Issue(title: "Hello, Moya!", createdAt: Date(), rating: 0)
        let endpoint = self.endpoint.replacing(task: .requestJSONEncodable(issue))
        let request = try endpoint.urlRequest()
        
        let expectedIssue = try JSONDecoder().decode(Issue.self, from: request.httpBody!)
        #expect(issue.createdAt == expectedIssue.createdAt)
        #expect(issue.title == expectedIssue.title)
        
        // updates headers to include Content-Type: application/json
        let contentTypeHeaders = ["Content-Type": "application/json"]
        let initialHeaderFields = endpoint.httpHeaderFields ?? [:]
        let expectedHTTPHeaderFields = initialHeaderFields.merging(contentTypeHeaders) { initialValue, _ in initialValue }
        #expect(request.allHTTPHeaderFields == expectedHTTPHeaderFields)
        
        // doesn't update any of the other properties
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("when task is .requestCustomJSONEncodable")
    func taskIsRequestCustomJSONEncodable() throws {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(formatter)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        let issue = Issue(title: "Hello, Moya!", createdAt: Date(), rating: 0)
        let endpoint = self.endpoint.replacing(task: .requestCustomJSONEncodable(issue, encoder: encoder))
        
        let request = try endpoint.urlRequest()
        
        // updates httpBody
        let expectedIssue = try decoder.decode(Issue.self, from: request.httpBody!)
        #expect(formatter.string(from: issue.createdAt) == formatter.string(from: expectedIssue.createdAt))
        #expect(issue.title == expectedIssue.title)
        
        // updates headers to include Content-Type: application/json
        let contentTypeHeaders = ["Content-Type": "application/json"]
        let initialHeaderFields = endpoint.httpHeaderFields ?? [:]
        let expectedHTTPHeaderFields = initialHeaderFields.merging(contentTypeHeaders) { initialValue, _ in initialValue }
        #expect(request.allHTTPHeaderFields == expectedHTTPHeaderFields)
        
        // doesn't update any of the other properties
        #expect(request.url?.absoluteString == endpoint.url)
        #expect(request.httpMethod == endpoint.method.rawValue)
    }
    
    @Test("when task is .requestCompositeParameters")
    func taskIsRequestCompositeParameters() throws {
        let bodyParameters = ["Nemesis": "Harvey"]
        let urlParameters = ["Harvey": "Nemesis"]
        let encoding = JSONEncoding.default
        let endpoint = endpoint.replacing(task: .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: encoding, urlParameters: urlParameters))
        let request = try endpoint.urlRequest()
        
        // updates url
        let expectedUrl = endpoint.url + "?Harvey=Nemesis"
        #expect(request.url?.absoluteString == expectedUrl)
        
        // updates the request correctly
        let newEndpoint = endpoint.replacing(task: .requestPlain)
        let newRequest = try newEndpoint.urlRequest()
        let newEncodedRequest = try encoding.encode(newRequest, with: bodyParameters)
        
        #expect(request.httpBody == newEncodedRequest.httpBody)
        #expect(request.allHTTPHeaderFields == newEncodedRequest.allHTTPHeaderFields)
        #expect(request.httpMethod == newEncodedRequest.httpMethod)
    }
    
    @Test("when task is .uploadCompositeMultipartFormData")
    func taskIsUploadCompositeMultipartFormData() throws {
        let urlParameters = ["Harvey": "Nemesis"]
        let endpoint = endpoint.replacing(task: .uploadCompositeMultipartFormData([], urlParameters: urlParameters))
        let request = try endpoint.urlRequest()
        
        // updates url
        let expectedUrl = endpoint.url + "?Harvey=Nemesis"
        #expect(request.url?.absoluteString == expectedUrl)
    }
    
    // MARK: - unsuccessful converting to urlRequest
    @Test("when url String is invalid, throws a .requestMapping error")
    func invalidURL() throws {
        let badEndpoint = Endpoint(url: "some invalid URL", sampleResponseClosure: { .networkResponse(200, Data()) }, method: .get, task: .requestPlain, httpHeaderFields: nil)
        let expectedError = MoyaError.requestMapping("some invalid URL")
        #expect(throws: MoyaError.self, performing: {
            try badEndpoint.urlRequest()
        })
    }
    
    @Test("when parameter encoding is unsuccessful, throws a .parameterEncoding error")
    func failParameterEncoding() {
        // Non-serializable type to cause serialization error
        final class InvalidParameter: Sendable {}
        
        let endpoint = endpoint.replacing(task: .requestParameters(parameters: ["": InvalidParameter()], encoding: PropertyListEncoding.default))
        let cocoaError = NSError(domain: "NSCocoaErrorDomain", code: 3851, userInfo: ["NSDebugDescription": "Property list invalid for format: 100 (property lists cannot contain objects of type 'CFType')"])
        let expectedError = MoyaError.parameterEncoding(cocoaError)
        
        #expect(throws: MoyaError.self, performing: {
            try endpoint.urlRequest()
        })
    }
    
    @Test("when JSONEncoder set with incorrect parameters, throws a .encodableMapping error")
    func encodableMappingFail() {
        let encoder = JSONEncoder()
        
        let issue = Issue(title: "Hello, Moya!", createdAt: Date(), rating: Float.infinity)
        let endpoint = endpoint.replacing(task: .requestCustomJSONEncodable(issue, encoder: encoder))
        
        let expectedError = MoyaError.encodableMapping(EncodingError.invalidValue(Float.infinity, EncodingError.Context(codingPath: [Issue.CodingKeys.rating], debugDescription: "Unable to encode Float.infinity directly in JSON. Use JSONEncoder.NonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.", underlyingError: nil)))
        
        #expect(throws: MoyaError.self, performing: {
            try endpoint.urlRequest()
        })
    }
    
    // FIXME: - https://github.com/Moya/Moya/blob/master/Tests/MoyaTests/EndpointSpec.swift#L372
    @Test("when task is .requestCompositeParameters", .disabled())
    func requestCompositeParametersFailConvertToRequest() throws {
        // throws an error when bodyEncoding is an URLEncoding.queryString
        let endpoint = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: [:], bodyEncoding: URLEncoding.queryString, urlParameters: [:]))
        #expect(throws: MoyaError.self, performing: {
            try endpoint.urlRequest()
        })
        
        // throws an error when bodyEncoding is an URLEncoding.default
        let endpoint2 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: [:], bodyEncoding: URLEncoding.default, urlParameters: [:]))
        #expect(throws: MoyaError.self, performing: {
            try endpoint2.urlRequest()
        })
        
        // doesn't throw an error when bodyEncoding is an URLEncoding.httpBody
        let endpoint3 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: [:], bodyEncoding: URLEncoding.httpBody, urlParameters: [:]))
        #expect(throws: Never.self, performing: {
            try endpoint3.urlRequest()
        })
    }
    
    // MARK: - given endpoint comparison
    @Test("when task is .uploadMultipartFormData")
    func compareUploadMultipartFormDataTask() throws {
        // should correctly acknowledge as equal for the same url, headers and form data
        let endpoint = endpoint.replacing(task: .uploadMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")])))
        let endpointToCompare = endpoint.replacing(task: .uploadMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")])))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different form data
        let endpoint2 = self.endpoint.replacing(task: .uploadMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")])))
        let endpointToCompare2 = endpoint.replacing(task: .uploadMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test1".data(using: .utf8)!), name: "test")])))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .uploadCompositeMultipartFormData")
    func compareUploadCompositeMultipartFormDataTask() throws {
        // should correctly acknowledge as equal for the same url, headers and form data
        let endpoint = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")]), urlParameters: [:]))
        let endpointToCompare = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")]), urlParameters: [:]))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different form data
        let endpoint2 = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")]), urlParameters: [:]))
        let endpointToCompare2 = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test1".data(using: .utf8)!), name: "test")]), urlParameters: [:]))
        #expect(endpoint2 != endpointToCompare2)
        
        // should correctly acknowledge as not equal for the same url, headers and different url parameters
        let endpoint3 = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")]), urlParameters: ["test": "test2"]))
        let endpointToCompare3 = self.endpoint.replacing(task: .uploadCompositeMultipartFormData(MultipartFormData(parts: [MultipartFormBodyPart(provider: .data("test".data(using: .utf8)!), name: "test")]), urlParameters: ["test": "test3"]))
        #expect(endpoint3 != endpointToCompare3)
    }
    
    @Test("when task is .uploadFile")
    func compareUploadFileTask() throws {
        // should correctly acknowledge as equal for the same url, headers and file
        let endpoint = self.endpoint.replacing(task: .uploadFile(URL(string: "https://google.com")!))
        let endpointToCompare = self.endpoint.replacing(task: .uploadFile(URL(string: "https://google.com")!))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different file
        let endpoint2 = self.endpoint.replacing(task: .uploadFile(URL(string: "https://google.com")!))
        let endpointToCompare2 = self.endpoint.replacing(task: .uploadFile(URL(string: "https://google.com?q=test")!))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .downloadDestination")
    func compareDownloadDestinationTask() throws {
        // should correctly acknowledge as equal for the same url, headers and download destination
        let endpoint = self.endpoint.replacing(task: .downloadDestination { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        })
        let endpointToCompare = self.endpoint.replacing(task: .downloadDestination { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        })
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as equal for the same url, headers and different download destination
        let endpoint2 = self.endpoint.replacing(task: .downloadDestination { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        })
        let endpointToCompare2 = self.endpoint.replacing(task: .downloadDestination { _, _ in
            return (destinationURL: URL(string: "https://google.com")!, options: [])
        })
        #expect(endpoint2 == endpointToCompare2)
    }
    
    @Test("when task is .downloadParameters")
    func compareDownloadParametersTask() throws {
        // should correctly acknowledge as equal for the same url, headers and download destination
        let endpoint = self.endpoint.replacing(task: .downloadParameters(parameters: ["test": "test2"], encoding: JSONEncoding.default, destination: { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        }))
        let endpointToCompare = self.endpoint.replacing(task: .downloadParameters(parameters: ["test": "test2"], encoding: JSONEncoding.default, destination: { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        }))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers, download destionation and different parameters
        let endpoint2 = self.endpoint.replacing(task: .downloadParameters(parameters: ["test": "test2"], encoding: JSONEncoding.default, destination: { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        }))
        let endpointToCompare2 = self.endpoint.replacing(task: .downloadParameters(parameters: ["test": "test3"], encoding: JSONEncoding.default, destination: { temporaryUrl, _ in
            return (destinationURL: temporaryUrl, options: [])
        }))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .requestCompositeData")
    func compareRequestCompositeDataTask() throws {
        // should correctly acknowledge as equal for the same url, headers, body and url parameters
        let endpoint = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test".data(using: .utf8)!, urlParameters: ["test": "test1"]))
        let endpointToCompare = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test".data(using: .utf8)!, urlParameters: ["test": "test1"]))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers, body and different url parameters
        let endpoint2 = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test".data(using: .utf8)!, urlParameters: ["test": "test1"]))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test".data(using: .utf8)!, urlParameters: ["test": "test2"]))
        #expect(endpoint2 != endpointToCompare2)
        
        // should correctly acknowledge as not equal for the same url, headers, url parameters and different body
        let endpoint3 = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test".data(using: .utf8)!, urlParameters: ["test": "test1"]))
        let endpointToCompare3 = self.endpoint.replacing(task: .requestCompositeData(bodyData: "test2".data(using: .utf8)!, urlParameters: ["test": "test1"]))
        #expect(endpoint3 != endpointToCompare3)
    }
    
    @Test("when task is .requestPlain")
    func compareRequestPlainTask() throws {
        // should correctly acknowledge as equal for the same url, headers and body
        let endpoint = self.endpoint.replacing(task: .requestPlain)
        let endpointToCompare = self.endpoint.replacing(task: .requestPlain)
        #expect(endpoint == endpointToCompare)
    }
    
    @Test("when task is .requestData")
    func compareRequestDataTask() throws {
        // should correctly acknowledge as equal for the same url, headers and data
        let endpoint = self.endpoint.replacing(task: .requestData("test".data(using: .utf8)!))
        let endpointToCompare = self.endpoint.replacing(task: .requestData("test".data(using: .utf8)!))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different data
        let endpoint2 = self.endpoint.replacing(task: .requestData("test".data(using: .utf8)!))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestData("test1".data(using: .utf8)!))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .requestJSONEncodable")
    func compareRequestJSONEncodableTask() throws {
        // should correctly acknowledge as equal for the same url, headers and encodable
        let date = Date()
        let endpoint = self.endpoint.replacing(task: .requestJSONEncodable(Issue(title: "T", createdAt: date, rating: 0)))
        let endpointToCompare = self.endpoint.replacing(task: .requestJSONEncodable(Issue(title: "T", createdAt: date, rating: 0)))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different encodable
        let endpoint2 = self.endpoint.replacing(task: .requestJSONEncodable(Issue(title: "T", createdAt: date, rating: 0)))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestJSONEncodable(Issue(title: "Ta", createdAt: date, rating: 0)))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .requestParameters")
    func compareRequestParametersTask() throws {
        // should correctly acknowledge as equal for the same url, headers and parameters
        let endpoint = self.endpoint.replacing(task: .requestParameters(parameters: ["test": "test1"], encoding: URLEncoding.queryString))
        let endpointToCompare = self.endpoint.replacing(task: .requestParameters(parameters: ["test": "test1"], encoding: URLEncoding.queryString))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers and different parameters
        let endpoint2 = self.endpoint.replacing(task: .requestParameters(parameters: ["test": "test1"], encoding: URLEncoding.queryString))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestParameters(parameters: ["test": "test2"], encoding: URLEncoding.queryString))
        #expect(endpoint2 != endpointToCompare2)
    }
    
    @Test("when task is .requestCompositeParameters")
    func compareRequestCompositeParametersTask() throws {
        // should correctly acknowledge as equal for the same url, headers, body and url parameters
        let endpoint = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test1"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test1"]))
        let endpointToCompare = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test1"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test1"]))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers, body parameters and different url parameters
        let endpoint2 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test1"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test1"]))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test1"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test2"]))
        #expect(endpoint2 != endpointToCompare2)

        // should correctly acknowledge as not equal for the same url, headers, url parameters and different body parameters
        let endpoint3 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test1"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test1"]))
        let endpointToCompare3 = self.endpoint.replacing(task: .requestCompositeParameters(bodyParameters: ["test": "test2"], bodyEncoding: JSONEncoding.default, urlParameters: ["url_test": "test1"]))
        #expect(endpoint3 != endpointToCompare3)
    }
    
    @Test("when task is .requestCustomJSONEncodable")
    func compareRequestCustomJSONEncodableTask() throws {
        // should correctly acknowledge as equal for the same url, headers, encodable and encoder
        let date = Date()
        let endpoint = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "T", createdAt: date, rating: 0), encoder: JSONEncoder()))
        let endpointToCompare = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "T", createdAt: date, rating: 0), encoder: JSONEncoder()))
        #expect(endpoint == endpointToCompare)
        
        // should correctly acknowledge as not equal for the same url, headers, encoder and different encodable
        let endpoint2 = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "T", createdAt: date, rating: 0), encoder: JSONEncoder()))
        let endpointToCompare2 = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "Ta", createdAt: date, rating: 0), encoder: JSONEncoder()))
        #expect(endpoint2 != endpointToCompare2)
        
        // should correctly acknowledge as not equal for the same url, headers, encodable and different encoder
        let endpoint3 = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "T", createdAt: date, rating: 0), encoder: JSONEncoder()))
        let snakeEncoder = JSONEncoder()
        snakeEncoder.keyEncodingStrategy = .convertToSnakeCase
        let endpointToCompare3 = self.endpoint.replacing(task: .requestCustomJSONEncodable(Issue(title: "T", createdAt: date, rating: 0), encoder: snakeEncoder))
        #expect(endpoint3 != endpointToCompare3)
    }
}
