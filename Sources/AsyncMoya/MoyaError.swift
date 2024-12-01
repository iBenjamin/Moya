//
//  MoyaError.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/1.
//

import Foundation

public enum MoyaError: Error, Sendable {
    /// The underlying reason the `.urlRequestValidationFailed` error occurred.
    public enum URLRequestValidationFailureReason: Sendable {
        /// URLRequest with GET method had body data.
        case bodyDataInGETRequest(Data)
    }
    
    /// The underlying reason the `.parameterEncodingFailed` error occurred.
    public enum ParameterEncodingFailureReason: Sendable {
        /// The `URLRequest` did not have a `URL` to encode.
        case missingURL
        /// JSON serialization failed with an underlying system error during the encoding process.
        case jsonEncodingFailed(error: any Error)
        /// Custom parameter encoding failed due to the associated `Error`.
        case customEncodingFailed(error: any Error)
    }
    
    /// `URLConvertible` type failed to create a valid `URL`.
    case invalidURL(url: any URLConvertible)
    
    /// `URLRequest` failed validation.
    case urlRequestValidationFailed(reason: URLRequestValidationFailureReason)
    
    /// `ParameterEncoding` threw an error during the encoding process.
    case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
    
    case invalidServerResponse(URLResponse)
    
    /// Indicates a response failed to map to an image.
    case imageMapping(Response)

    /// Indicates a response failed to map to a JSON structure.
    case jsonMapping(Response)

    /// Indicates a response failed to map to a String.
    case stringMapping(Response)

    /// Indicates a response failed to map to a Decodable object.
    case objectMapping(Swift.Error, Response)

    /// Indicates that Encodable couldn't be encoded into Data
    case encodableMapping(Swift.Error)

    /// Indicates a response failed with an invalid HTTP status code.
    case statusCode(Response)

    /// Indicates a response failed due to an underlying `Error`.
    case underlying(Swift.Error, Response?)

    /// Indicates that an `Endpoint` failed to map to a `URLRequest`.
    case requestMapping(String)

    /// Indicates that an `Endpoint` failed to encode the parameters for the `URLRequest`.
    case parameterEncoding(Swift.Error)
}

public extension MoyaError {
    /// Depending on error type, returns a `Response` object.
    var response: Response? {
        switch self {
        case .imageMapping(let response): return response
        case .jsonMapping(let response): return response
        case .stringMapping(let response): return response
        case .objectMapping(_, let response): return response
        case .encodableMapping: return nil
        case .statusCode(let response): return response
        case .underlying(_, let response): return response
        case .requestMapping: return nil
        case .parameterEncoding: return nil
        case .invalidURL(url: let url):
            return nil
        case .urlRequestValidationFailed(reason: let reason):
            return nil
        case .parameterEncodingFailed(reason: let reason):
            return nil
        case .invalidServerResponse(_):
            return nil
        }
    }

    /// Depending on error type, returns an underlying `Error`.
    internal var underlyingError: Swift.Error? {
        switch self {
        case .imageMapping: return nil
        case .jsonMapping: return nil
        case .stringMapping: return nil
        case .objectMapping(let error, _): return error
        case .encodableMapping(let error): return error
        case .statusCode: return nil
        case .underlying(let error, _): return error
        case .requestMapping: return nil
        case .parameterEncoding(let error): return error
        case .invalidURL(url: let url):
            return nil
        case .urlRequestValidationFailed(reason: let reason):
            return nil
        case .parameterEncodingFailed(reason: let reason):
            return nil
        case .invalidServerResponse(_):
            return nil
        }
    }
}

// MARK: - Error Descriptions

extension MoyaError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .imageMapping:
            return "Failed to map data to an Image."
        case .jsonMapping:
            return "Failed to map data to JSON."
        case .stringMapping:
            return "Failed to map data to a String."
        case .objectMapping:
            return "Failed to map data to a Decodable object."
        case .encodableMapping:
            return "Failed to encode Encodable object into data."
        case .statusCode:
            return "Status code didn't fall within the given range."
        case .underlying(let error, _):
            return error.localizedDescription
        case .requestMapping:
            return "Failed to map Endpoint to a URLRequest."
        case .parameterEncoding(let error):
            return "Failed to encode parameters for URLRequest. \(error.localizedDescription)"
        case .invalidURL(url: let url):
            return "Invalid url: \(url)"
        case .urlRequestValidationFailed(reason: let reason):
            return "Url request validation failed: \(reason)"
        case .parameterEncodingFailed(reason: let reason):
            return "Parameter encoding failed: \(reason)"
        case .invalidServerResponse(let urlResponse):
            return "Invalid server response: \(urlResponse)"
        }
    }
}

// MARK: - Error User Info

extension MoyaError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [:]
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }
}
