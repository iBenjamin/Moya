//
//  File.swift
//  AsyncMoya
//
//  Created by Benjamin Wong on 2024/11/30.
//

import Foundation
import Testing
import AsyncMoya

@Test("test method supports multipart")
func testMethodSupportsMultipart() {
    let expectations: [(HTTPMethod, Bool)] = [
        (.get, false),
        (.post, true),
        (.put, true),
        (.delete, false),
        (.options, false),
        (.head, false),
        (.patch, true),
        (.trace, false),
        (.connect, true)
    ]
    for (method, expected) in expectations {
        #expect(method.supportsMultipart == expected)
    }
}
