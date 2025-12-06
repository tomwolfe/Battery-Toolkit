//
// Copyright (C) 2022 - 2025 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import BTPreprocessor
import Foundation
import os.log

@BTBackgroundActor
internal enum BTDaemonXPCClient {
    private static var connect: NSXPCConnection? = nil

    static func disconnectDaemon() {
        guard let connect = self.connect else {
            return
        }

        self.connect = nil
        connect.invalidate()
    }

    static func getUniqueId() async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.getUniqueId { data in
                    guard let data = data else {
                        continuation.resume(throwing: BTError.malformedData)
                        return
                    }

                    continuation.resume(returning: data)
                }
            }
        }
    }

    static func getState() async throws -> [String: NSObject & Sendable] {
        try await withCheckedThrowingContinuation { continuation in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.getState { state in
                    continuation.resume(returning: state)
                }
            }
        }
    }

    static func disablePowerAdapter() async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: authData,
                command: BTDaemonCommCommand.disablePowerAdapter
            )
        }
    }

    static func enablePowerAdapter() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: nil,
                command: BTDaemonCommCommand.enablePowerAdapter
            )
        }
    }

    static func chargeToLimit() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: nil,
                command: BTDaemonCommCommand.chargeToLimit
            )
        }
    }

    static func chargeToFull() async throws {
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: nil,
                command: BTDaemonCommCommand.chargeToFull
            )
        }
    }

    static func disableCharging() async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: authData,
                command: BTDaemonCommCommand.disableCharging
            )
        }
    }

    static func pauseActivity() async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: authData,
                command: BTDaemonCommCommand.pauseActivity
            )
        }
    }

    static func resumeActivity() async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { continuation in
            self.runExecute(
                continuation: continuation,
                authData: authData,
                command: BTDaemonCommCommand.resumeActivity
            )
        }
    }

    static func getSettings() async throws -> [String: NSObject & Sendable] {
        try await withCheckedThrowingContinuation { continuation in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.getSettings { settings in
                    continuation.resume(returning: settings)
                }
            }
        }
    }

    static func setSettings(settings: [String: NSObject & Sendable]) async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.setSettings(
                    authData: authData,
                    settings: settings,
                    reply: self.continuationStatusHandler(continuation: continuation)
                )
            }
        }
    }

    static func prepareUpdate() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.execute(
                    authData: nil,
                    command: BTDaemonCommCommand.prepareUpdate.rawValue,
                    reply: self.continuationStatusHandler(continuation: continuation)
                )
            }
        }
    }

    static func finishUpdate() {
        Task {
            do {
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
                    self.runExecute(continuation: continuation, authData: nil, command: BTDaemonCommCommand.finishUpdate)
                }
            }
            catch {
                //
                // Deliberately ignore errors as this is an optional notification.
                //
            }
        }
    }

    static func removeLegacyHelperFiles(authData: Data) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.executeDaemonRetryWithBackoff(continuation: continuation) { daemon in
                daemon.execute(
                    authData: authData,
                    command: BTDaemonCommCommand.removeLegacyHelperFiles.rawValue,
                    reply: self.continuationStatusHandler(continuation: continuation)
                )
            }
        }
    }

    static func prepareDisable(authData: Data) async throws {
        let authData = try await BTAppXPCClient.getManageAuthorization()
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.runExecute(continuation: continuation, authData: authData, command: BTDaemonCommCommand.prepareDisable)
        }
    }

    static func isSupported() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, any Error>) in
            self.runExecute(continuation: continuation, authData: nil, command: BTDaemonCommCommand.isSupported)
        }
    }

    private static func continuationStatusHandler(continuation: CheckedContinuation<Void, any Error>) -> (@Sendable (BTError.RawValue) -> Void) {
        return { error in
            guard error == BTError.success.rawValue else {
                continuation.resume(throwing: BTError.init(rawValue: error)!)
                return
            }
            continuation.resume()
        }
    }
    
    private static func connectDaemon() -> NSXPCConnection {
        // Check if existing connection is still valid
        if let connect = self.connect, connect.invalidationReason == nil {
            // Check if the connection is still responding
            if connect.remoteObjectInterface != nil {
                return connect
            }
        }

        // Disconnect any invalid connection
        if let connect = self.connect, connect.invalidationReason != nil {
            connect.invalidate()
        }

        let connect = NSXPCConnection(
            machServiceName: BT_DAEMON_CONN,
            options: .privileged
        )
        connect.remoteObjectInterface = NSXPCInterface(
            with: BTDaemonCommProtocol.self
        )

        // Add better error handling to the connection
        connect.invalidationHandler = { [weak connect] in
            os_log("XPC client connection invalidated: %@",
                   connect?.invalidationReason ?? "Unknown reason")
        }

        connect.interruptionHandler = {
            os_log("XPC client connection interrupted, will attempt to reconnect when needed")
        }

        BTXPCValidation.protectDaemon(connection: connect)

        connect.resume()
        self.connect = connect

        os_log("XPC client connected")

        return connect
    }

    private static func executeDaemon(
        command: @BTBackgroundActor @Sendable (BTDaemonCommProtocol) -> Void,
        errorHandler: @escaping @Sendable (any Error) -> Void
    ) {
        let connect = self.connectDaemon()
        let daemon = connect.remoteObjectProxyWithErrorHandler(
            errorHandler
        ) as! BTDaemonCommProtocol
        command(daemon)
    }

    private static func executeDaemonRetry<T>(
        continuation: CheckedContinuation<T, any Error>,
        command: @BTBackgroundActor @escaping @Sendable (BTDaemonCommProtocol) -> Void
    ) {
        self.executeDaemon(command: command) { error in
            os_log("XPC client remote error: \(error, privacy: .public))")
            os_log("Retrying...")
            Task { @BTBackgroundActor in
                self.disconnectDaemon()
                // Wait a bit before retry to allow system to stabilize
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                self.executeDaemon(command: command) { error in
                    os_log("XPC client remote error after retry: \(error, privacy: .public))")
                    continuation.resume(throwing: BTError.commFailed)
                }
            }
        }
    }

    private static func executeDaemonManageRetry<T>(
        continuation: CheckedContinuation<T, any Error>,
        command: @BTBackgroundActor @escaping @Sendable (BTDaemonCommProtocol) -> Void
    ) {
        self.executeDaemonRetry(continuation: continuation, command: command)
    }

    /// Enhanced retry mechanism with exponential backoff for critical operations
    private static func executeDaemonRetryWithBackoff<T>(
        continuation: CheckedContinuation<T, any Error>,
        maxRetries: Int = 3,
        currentRetry: Int = 0,
        command: @BTBackgroundActor @escaping @Sendable (BTDaemonCommProtocol) -> Void
    ) {
        self.executeDaemon(command: command) { error in
            if currentRetry < maxRetries {
                os_log("XPC client remote error: \(error, privacy: .public)) - Attempt %d of %d",
                       currentRetry + 1, maxRetries + 1)

                Task { @BTBackgroundActor in
                    self.disconnectDaemon()
                    // Exponential backoff: wait 0.5s, 1s, 2s for retries
                    let delay = UInt64(pow(2.0, Double(currentRetry)) * 500_000_000)
                    try? await Task.sleep(nanoseconds: delay)

                    self.executeDaemonRetryWithBackoff(
                        continuation: continuation,
                        maxRetries: maxRetries,
                        currentRetry: currentRetry + 1,
                        command: command
                    )
                }
            } else {
                os_log("XPC client remote error after %d retries: \(error, privacy: .public))", maxRetries + 1)
                continuation.resume(throwing: BTError.connectionTimeout)
            }
        }
    }

    private static func runExecute(
        continuation: CheckedContinuation<Void, any Error>,
        authData: Data?,
        command: BTDaemonCommCommand
    ) {
        self.executeDaemonManageRetry(continuation: continuation) { daemon in
            daemon.execute(
                authData: authData,
                command: command.rawValue,
                reply: self.continuationStatusHandler(continuation: continuation)
            )
        }
    }
}
