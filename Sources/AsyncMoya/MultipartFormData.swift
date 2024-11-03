import Foundation
import Alamofire

/// Represents "multipart/form-data" for an upload.
public struct MultipartFormData: Hashable {

    /// Method to provide the form data.
    public enum FormDataProvider: Hashable {
        case data(Foundation.Data)
        case file(URL)
        case stream(InputStream, UInt64)
    }

    /// `FileManager` to use for file operations, if needed. `FileManager.default` by default.
    public let fileManager: FileManager

    /// Separates ``parts`` in the encoded form data. `nil` by default.
    public let boundary: String?

    /// Blocks of data to send, separated with ``boundary``.
    public let parts: [MultipartFormBodyPart]

    public init(fileManager: FileManager = .default, boundary: String? = nil, parts: [MultipartFormBodyPart]) {
        self.fileManager = fileManager
        self.boundary = boundary
        self.parts = parts
    }
}

extension MultipartFormData: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: MultipartFormBodyPart...) {
        self.init(parts: elements)
    }
}

/// Represents the body part of "multipart/form-data" for an upload.
public struct MultipartFormBodyPart: Hashable {

    public init(provider: MultipartFormData.FormDataProvider, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }

    /// The method being used for providing form data.
    public let provider: MultipartFormData.FormDataProvider

    /// The name.
    public let name: String

    /// The file name.
    public let fileName: String?

    /// The MIME type
    public let mimeType: String?

}
