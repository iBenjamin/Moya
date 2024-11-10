import Nimble

/// A Nimble matcher that succeeds when at least one of the substrings
public func containOne(of substrings: String...) -> Matcher<String> {
    containOne(of: substrings)
}

/// A Nimble matcher that succeeds when at least one of the substrings
public func containOne(of substrings: [String]) -> Matcher<String> {
    let containArrayAsString = substrings.map { "<\($0)>" }.joined(separator: " or ")
    return Matcher.simple("contain \(containArrayAsString)") { actualExpression in
        if let actual = try actualExpression.evaluate() {
            let foundSubsring = substrings.first(where: { actual.contains($0) })
            return MatcherStatus(bool: foundSubsring != nil)
        }
        return .fail
    }
}
