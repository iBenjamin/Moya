import Nimble
import AsyncMoya

public func beOfSameErrorType(_ expectedValue: MoyaError) -> Matcher<MoyaError> {
    Matcher { expression -> MatcherResult in
        let test: Bool
        if let value = try expression.evaluate() {
            switch value {
            case .imageMapping:
                switch expectedValue {
                case .imageMapping:
                    test = true
                default:
                    test = false
                }
            case .jsonMapping:
                switch expectedValue {
                case .jsonMapping:
                    test = true
                default:
                    test = false
                }
            case .stringMapping:
                switch expectedValue {
                case .stringMapping:
                    test = true
                default:
                    test = false
                }
            case .objectMapping:
                switch expectedValue {
                case .objectMapping:
                    test = true
                default:
                    test = false
                }
            case .encodableMapping:
                switch expectedValue {
                case .encodableMapping:
                    test = true
                default:
                    test = false
                }
            case .statusCode:
                switch expectedValue {
                case .statusCode:
                    test = true
                default:
                    test = false
                }
            case .underlying:
                switch expectedValue {
                case .underlying:
                    test = true
                default:
                    test = false
                }
            case .requestMapping:
                switch expectedValue {
                case .requestMapping:
                    test = true
                default:
                    test = false
                }
            case .parameterEncoding:
                switch expectedValue {
                case .parameterEncoding:
                    test = true
                default:
                    test = false
                }
            case .invalidURL:
                switch expectedValue {
                case .invalidURL:
                    test = true
                default:
                    test = false
                }
            case .urlRequestValidationFailed:
                switch expectedValue {
                case .urlRequestValidationFailed:
                    test = true
                default:
                    test = false
                }
            case .parameterEncodingFailed:
                switch expectedValue {
                case .parameterEncoding:
                    test = true
                default:
                    test = false
                }
            case .invalidServerResponse:
                switch expectedValue {
                case .invalidServerResponse:
                    test = true
                default:
                    test = false
                }
            }
        } else {
            test = false
        }

        return MatcherResult(bool: test, message: .expectedActualValueTo("<\(expectedValue)>"))
    }
}
