//
// Copyright (C) 2022 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation

internal enum BTLocalization {
    enum Prompts {
        static let ok = NSLocalizedString(
            "OK",
            comment: "Prompt button to acknowledge a situation"
        )

        static let approve = NSLocalizedString(
            "Approve",
            comment: "Prompt button to approve an action"
        )

        static let cancel = NSLocalizedString(
            "Cancel",
            comment: "Prompt button to cancel an action"
        )

        static let retry = NSLocalizedString(
            "Retry",
            comment: "Prompt button to retry an action"
        )

        static let quit = NSLocalizedString(
            "Quit",
            comment: "Prompt button to quit the app"
        )

        static let disableAndQuit = NSLocalizedString(
            "Disable and Quit",
            comment: "Prompt button to disable a core function and quit the app"
        )

        static let openSystemSettings = NSLocalizedString(
            "Open System Settings",
            comment: "Prompt button to open System Settings"
        )

        static let quitMessage = NSLocalizedString(
            "Quit Battery Toolkit?",
            comment: "Prompt caption asking whether to quit the app"
        )

        static let quitInfo = NSLocalizedString(
            "Battery Toolkit will continue to run in the background. To permanently suspend it, disable the background activity from the Battery Toolkit menu.",
            comment: "Prompt caption asking whether to quit the app"
        )

        static let quitInfoMacOS13 = NSLocalizedString(
            "To temporarily suspend it, disable the background activity in System Settings.",
            comment: "Prompt caption asking whether to quit the app"
        )

        static let unexpectedErrorMessage = NSLocalizedString(
            "An unexpected error has occured.",
            comment: "Prompt caption informing the user of an unexpected error"
        )

        static let notAuthorizedMessage = NSLocalizedString(
            "You do not have permission to perform this operation.",
            comment: "Prompt caption informing the user that they are not authorized to perform a specific operation"
        )

        static let connectionTimeoutMessage = NSLocalizedString(
            "Connection to service timed out.",
            comment: "Prompt caption informing the user that the connection to the service timed out"
        )

        static let connectionTimeoutInfo = NSLocalizedString(
            "The connection to the background service timed out. Please try again later.",
            comment: "Prompt text explaining the connection timeout"
        )

        static let invalidResponseMessage = NSLocalizedString(
            "Service returned an invalid response.",
            comment: "Prompt caption informing the user that the service returned an invalid response"
        )

        static let invalidResponseInfo = NSLocalizedString(
            "The background service returned an unexpected response. This may indicate a communication issue.",
            comment: "Prompt text explaining the invalid response"
        )

        static let operationFailedMessage = NSLocalizedString(
            "Operation failed to complete.",
            comment: "Prompt caption informing the user that the operation failed"
        )

        static let operationFailedInfo = NSLocalizedString(
            "The requested operation could not be completed. Please try again.",
            comment: "Prompt text explaining that the operation failed"
        )

        static let serviceUnavailableMessage = NSLocalizedString(
            "Required service is currently unavailable.",
            comment: "Prompt caption informing the user that the required service is unavailable"
        )

        static let serviceUnavailableInfo = NSLocalizedString(
            "The background service needed to perform this operation is currently unavailable.",
            comment: "Prompt text explaining that the required service is unavailable"
        )

        static let malformedDataMessage = NSLocalizedString(
            "Received malformed data from service.",
            comment: "Prompt caption informing the user that malformed data was received from the service"
        )

        static let malformedDataInfo = NSLocalizedString(
            "The service returned data in an unexpected format. This may indicate a compatibility issue.",
            comment: "Prompt text explaining malformed data from service"
        )

        enum Daemon {
            static let requiredInfo = NSLocalizedString(
                "To manage the power state of your Mac, Battery Toolkit needs to run in the background.",
                comment: "Prompt text explaining the requirement for background activity"
            )

            static let allowMessage = NSLocalizedString(
                "Allow background activity?",
                comment: "Prompt caption asking to allow background activity"
            )

            static let allowInfo = NSLocalizedString(
                "Do you want to approve the Battery Toolkit Login Item in System Settings?",
                comment: "Prompt text asking to approve background activity"
            )

            static let enableFailMessage = NSLocalizedString(
                "Failed to enable background activity.",
                comment: "Prompt caption informing of failure to enable background activity"
            )

            static let disableMessage = NSLocalizedString(
                "Disable background activity?",
                comment: "Prompt caption asking whether to disable background activity"
            )

            static let disableInfo = NSLocalizedString(
                "Do you want to disable background activity for Battery Toolkit?",
                comment: "Prompt text asking whether to disable background activity"
            )

            static let disableFailMessage = NSLocalizedString(
                "An error occurred disabling background activity.",
                comment: "Prompt caption informing of failure to disable background activity"
            )

            static let commFailMessage = NSLocalizedString(
                "Failed to communicate with the background service.",
                comment: "Prompt caption informing the user that the app failed to communicate with its background service"
            )

            static let commFailInfo = NSLocalizedString(
                "Please restart your Mac and try again. If the problem persists, contact the developers.",
                comment: "Prompt text instructing the user to restart the machine and try again"
            )

            static let unsupportedMessage = NSLocalizedString(
                "Your Mac is not supported.",
                comment: "Prompt caption informing the user that the app does not support this machine"
            )

            static let unsupportedInfo = NSLocalizedString(
                "Battery Toolkit does not support managing the power state of your Mac. Background activity will be disabled.",
                comment: "Prompt text informing the user the app does not support this machine and that background activity will be disabled in response"
            )
        }
    }

    static let preferences = NSLocalizedString(
        "Preferences",
        comment: "Preferences for macOS 12 and below"
    )
}
