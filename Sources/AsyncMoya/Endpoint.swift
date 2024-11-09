import Foundation

/// Used for stubbing responses.
public enum EndpointSampleResponse {
    
    /// The network returned a response, including status code and data.
    case networkResponse(Int, Data)
    
    /// The network returned response which can be fully customized.
    case response(HTTPURLResponse, Data)
    
    /// The network failed to send the request, or failed to retrieve a response (eg a timeout).
    case networkError(NSError)
}

public struct Endpoint: Sendable {
    public typealias SampleResponseClosure = @Sendable () -> EndpointSampleResponse
    
    /// A string representation of the URL for the request.
    public let url: String
    
    /// A closure responsible for returning an `EndpointSampleResponse`.
    public let sampleResponseClosure: SampleResponseClosure
    
    /// The HTTP method for the request.
    public let method: HTTPMethod
    
    /// The `Task` for the request.
    public let task: Task
    
    /// The HTTP header fields for the request.
    public let httpHeaderFields: [String: String]?
    
    public init(url: String, sampleResponseClosure: @escaping SampleResponseClosure, method: HTTPMethod, task: Task, httpHeaderFields: [String : String]?) {
        self.url = url
        self.sampleResponseClosure = sampleResponseClosure
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }
}

/// Extension for converting an `Endpoint` into a `URLRequest`.
public extension Endpoint {
    // swiftlint:disable cyclomatic_complexity
    /// Returns the `Endpoint` converted to a `URLRequest` if valid. Throws an error otherwise.
    func urlRequest() throws -> URLRequest {
        guard let requestURL = Foundation.URL(string: url) else {
            throw MoyaError.requestMapping(url)
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeaderFields

        switch task {
        case .requestPlain, .uploadFile, .uploadMultipartFormData, .downloadDestination:
            return request
        case .requestData(let data):
            request.httpBody = data
            return request
        case let .requestJSONEncodable(encodable):
            return try request.encoded(encodable: encodable)
        case let .requestCustomJSONEncodable(encodable, encoder: encoder):
            return try request.encoded(encodable: encodable, encoder: encoder)
        case let .requestParameters(parameters, parameterEncoding):
            return try request.encoded(parameters: parameters, parameterEncoding: parameterEncoding)
        case let .uploadCompositeMultipartFormData(_, urlParameters):
            let parameterEncoding = URLEncoding(destination: .queryString)
            return try request.encoded(parameters: urlParameters, parameterEncoding: parameterEncoding)
        case let .downloadParameters(parameters, parameterEncoding, _):
            return try request.encoded(parameters: parameters, parameterEncoding: parameterEncoding)
        case let .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters):
            request.httpBody = bodyData
            let parameterEncoding = URLEncoding(destination: .queryString)
            return try request.encoded(parameters: urlParameters, parameterEncoding: parameterEncoding)
        case let .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyParameterEncoding, urlParameters: urlParameters):
            if let bodyParameterEncoding = bodyParameterEncoding as? URLEncoding, bodyParameterEncoding.destination != .httpBody {
                fatalError("Only URLEncoding that `bodyEncoding` accepts is URLEncoding.httpBody. Others like `default`, `queryString` or `methodDependent` are prohibited - if you want to use them, add your parameters to `urlParameters` instead.")
            }
            let bodyfulRequest = try request.encoded(parameters: bodyParameters, parameterEncoding: bodyParameterEncoding)
            let urlEncoding = URLEncoding(destination: .queryString)
            return try bodyfulRequest.encoded(parameters: urlParameters, parameterEncoding: urlEncoding)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}
