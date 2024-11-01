import Foundation

/// Provides each request with optional URLCredentials.
public final class CredentialsPlugin: PluginType, @unchecked Sendable {

    public typealias CredentialClosure = (TargetType) -> URLCredential?
    let credentialsClosure: CredentialClosure

    /// Initializes a CredentialsPlugin.
    public init(credentialsClosure: @escaping CredentialClosure) {
        self.credentialsClosure = credentialsClosure
    }

    // MARK: Plugin

    public func willSend(_ request: RequestType, target: TargetType) {
        if let credentials = credentialsClosure(target) {
            _ = request.authenticate(with: credentials)
        }
    }
}
