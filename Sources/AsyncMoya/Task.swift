//
//  Task.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/1.
//

import Foundation

public enum Task: @unchecked Sendable {
    
    /// A request with no additional data.
    case requestPlain
    
    /// A requests body set with data.
    case requestData(Data)
    
    /// A request body set with `Encodable` type
    case requestJSONEncodable(Encodable)
    
    /// A request body set with `Encodable` type and custom encoder
    case requestCustomJSONEncodable(Encodable, encoder: JSONEncoder)
    
    /// A requests body set with encoded parameters.
    case requestParameters(parameters: Parameters, encoding: ParameterEncoding)
    
    /// A requests body set with data, combined with url parameters.
    case requestCompositeData(bodyData: Data, urlParameters: Parameters)
    
    /// A requests body set with encoded parameters combined with url parameters.
    case requestCompositeParameters(bodyParameters: Parameters, bodyEncoding: ParameterEncoding, urlParameters: Parameters)
    
    /// A file upload task.
    case uploadFile(URL)
    
    /// A "multipart/form-data" upload task.
    case uploadMultipartFormData(MultipartFormData)
    
    /// A "multipart/form-data" upload task  combined with url parameters.
    case uploadCompositeMultipartFormData(MultipartFormData, urlParameters: Parameters)
    
    /// A file download task to a destination.
    case downloadDestination(Destination)

    /// A file download task to a destination with extra parameters using the given encoding.
    case downloadParameters(parameters: Parameters, encoding: ParameterEncoding, destination: Destination)
}

// MARK: Destination

/// A closure executed once a `DownloadRequest` has successfully completed in order to determine where to move the
/// temporary file written to during the download process. The closure takes two arguments: the temporary file URL
/// and the `HTTPURLResponse`, and returns two values: the file URL where the temporary file should be moved and
/// the options defining how the file should be moved.
///
/// - Note: Downloads from a local `file://` `URL`s do not use the `Destination` closure, as those downloads do not
///         return an `HTTPURLResponse`. Instead the file is merely moved within the temporary directory.
public typealias Destination = @Sendable (_ temporaryURL: URL,
                                          _ response: HTTPURLResponse) -> (destinationURL: URL, options: Options)

/// A set of options to be executed prior to moving a downloaded file from the temporary `URL` to the destination
/// `URL`.
public struct Options: OptionSet, Sendable {
    /// Specifies that intermediate directories for the destination URL should be created.
    public static let createIntermediateDirectories = Options(rawValue: 1 << 0)
    /// Specifies that any previous file at the destination `URL` should be removed.
    public static let removePreviousFile = Options(rawValue: 1 << 1)

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
