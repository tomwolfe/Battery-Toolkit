//
// Copyright (C) 2022 - 2025 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

internal enum BTError: UInt8, Error {
    case success
    case unknown
    case notAuthorized
    case commFailed
    case malformedData
    case unsupported
    case connectionTimeout
    case invalidResponse
    case operationFailed
    case serviceUnavailable

    init(fromBool: Bool) {
        self = fromBool ? .success : .unknown
    }

    /// Human-readable error description for better user feedback
    var localizedDescription: String {
        switch self {
        case .success:
            return "Operation completed successfully"
        case .unknown:
            return "An unknown error occurred"
        case .notAuthorized:
            return "Permission denied - authorization required"
        case .commFailed:
            return "Communication with Background Activity failed"
        case .malformedData:
            return "Communication issue with Background Activity"
        case .unsupported:
            return "This operation is not supported on your device"
        case .connectionTimeout:
            return "Connection to Background Activity timed out"
        case .invalidResponse:
            return "Communication issue with Background Activity"
        case .operationFailed:
            return "Operation failed to complete"
        case .serviceUnavailable:
            return "Communication issue with Background Activity"
        }
    }
}
