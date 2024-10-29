import Foundation
import Alamofire

/// Represents an HTTP task.
@preconcurrency
public enum Task {

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

    /// A "multipart/form-data" upload task.
    @available(*, deprecated, message: "use `uploadMultipartFormData(MultipartFormData)` instead")
    case uploadMultipart([MultipartFormBodyPart])

    /// A "multipart/form-data" upload task  combined with url parameters.
    case uploadCompositeMultipartFormData(MultipartFormData, urlParameters: Parameters)

    /// A "multipart/form-data" upload task  combined with url parameters.
    @available(*, deprecated, message: "use `uploadCompositeMultipartFormData(MultipartFormData)` instead")
    case uploadCompositeMultipart([MultipartFormBodyPart], urlParameters: Parameters)

    /// A file download task to a destination.
    case downloadDestination(DownloadDestination)

    /// A file download task to a destination with extra parameters using the given encoding.
    case downloadParameters(parameters: Parameters, encoding: ParameterEncoding, destination: DownloadDestination)
}
