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
