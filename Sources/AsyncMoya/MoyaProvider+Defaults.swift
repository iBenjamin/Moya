import Foundation

/// These functions are default mappings to `MoyaProvider`'s properties: endpoints, requests, session etc.
public extension MoyaProvider {
    static func defaultEndpointMapping(for target: Target) -> Endpoint {
        Endpoint(
            url: URL(target: target).absoluteString,
            sampleResponseClosure: { [data = target.sampleData] in  .networkResponse(200, data) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    static func defaultRequestMapping(for endpoint: Endpoint, closure: RequestResultClosure) {
        do {
            let urlRequest = try endpoint.urlRequest()
            closure(.success(urlRequest))
        } catch MoyaError.requestMapping(let url) {
            closure(.failure(MoyaError.requestMapping(url)))
        } catch MoyaError.parameterEncoding(let error) {
            closure(.failure(MoyaError.parameterEncoding(error)))
        } catch {
            closure(.failure(MoyaError.underlying(error, nil)))
        }
    }
}
