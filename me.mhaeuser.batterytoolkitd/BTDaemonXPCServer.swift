//
// Copyright (C) 2022 - 2024 Marvin Häuser. All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
//

import Foundation
import os.log

import BTPreprocessor
import NSXPCConnectionAuditToken
import Security

internal enum BTDaemonXPCServer {
    @MainActor private static let listener = NSXPCListener(
        machServiceName: BT_DAEMON_CONN
    )

    private static let delegate: Delegate = Delegate()

    private static let daemonComm = BTDaemonComm()

    @MainActor static func start() {
        self.listener.delegate = self.delegate
        self.listener.resume()
    }
}

private extension BTDaemonXPCServer {
    final class Delegate: NSObject, NSXPCListenerDelegate, Sendable {
        func listener(
            _: NSXPCListener,
            shouldAcceptNewConnection newConnection: NSXPCConnection
        ) -> Bool {
            guard BTXPCValidation.isValidClient(connection: newConnection)
            else {
                os_log("XPC server connection by invalid client")
                return false
            }

            newConnection.exportedInterface = NSXPCInterface(with: BTDaemonCommProtocol.self)
            newConnection.exportedObject = BTDaemonXPCServer.daemonComm

            // Add error handling for the connection
            newConnection.interruptionHandler = {
                os_log("XPC server connection interrupted")
            }

            newConnection.invalidationHandler = {
                os_log("XPC server connection invalidated")
            }

            newConnection.resume()

            os_log("XPC server connection accepted")
            return true
        }
    }
}
