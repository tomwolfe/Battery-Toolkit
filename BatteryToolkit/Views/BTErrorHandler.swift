//
// Copyright (C) 2022 - 2025 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import Cocoa
import os.log

internal enum BTErrorHandler {
    @MainActor static func errorHandler(
        error: any Error,
        window: NSWindow? = nil
    ) {
        // Log the error for debugging purposes
        if let btError = error as? BTError {
            os_log("Error occurred: %s", type: .error, btError.localizedDescription)
        } else {
            os_log("Unknown error occurred: %@", type: .error, String(describing: error))
        }

        guard let error = error as? BTError else {
            os_log("Non-BTError caught: %@", type: .error, String(describing: error))
            self.errorHandler(error: BTError.unknown, window: window)
            return
        }

        assert(error != BTError.success)

        switch error {
        case .notAuthorized:
            BTAppPrompts.promptNotAuthorized(window: window)

        case .commFailed:
            BTAppPrompts.promptDaemonCommFailed(window: window)

        case .connectionTimeout:
            BTAppPrompts.promptConnectionTimeout(window: window)

        case .invalidResponse:
            BTAppPrompts.promptInvalidResponse(window: window)

        case .operationFailed:
            BTAppPrompts.promptOperationFailed(window: window, message: error.localizedDescription)

        case .serviceUnavailable:
            BTAppPrompts.promptServiceUnavailable(window: window)

        case .malformedData:
            BTAppPrompts.promptMalformedData(window: window)

        case .unsupported:
            Task { await BTAppPrompts.promptMachineUnsupported() }

        case .unknown:
            BTAppPrompts.promptUnexpectedError(window: window)
        }
    }
}
