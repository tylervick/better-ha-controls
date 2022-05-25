//
//  NetworkDiscovery.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/15/22.
//

import Foundation
import Network

class NetworkDiscovery {
    private static let serviceType = "_home-assistant._tcp"
    private static let domain = "local."

    let browser = NWBrowser(
        for: .bonjour(type: NetworkDiscovery.serviceType, domain: NetworkDiscovery.domain),
        using: .tcp
    )

    @Published var endpoints: Set<NWEndpoint> = []
    
    func start() {
        browser.start(queue: .global())
    }
    
    func stop() {
        browser.cancel()
    }

    private func browseResultsChangedHandler(
        _ newResults: Set<NWBrowser.Result>, _ changes: Set<NWBrowser.Result.Change>
    ) {
        changes.forEach {
            switch $0 {
            case .added(let result):
                endpoints.insert(result.endpoint)
            case .changed(let oldResult, let newResult, _):
                endpoints.remove(oldResult.endpoint)
                endpoints.insert(newResult.endpoint)
            case .removed(let result):
                endpoints.remove(result.endpoint)
            default:
                break
            }
        }
    }

    private func onConnectionReady(_ connection: NWConnection) {

        guard connection.state == .ready else {
            return
        }

        guard let remoteEndpoint = connection.currentPath?.remoteEndpoint else {
            return
        }

        if case let .hostPort(host, port) = remoteEndpoint,
            case let .ipv4(ipv4Addr) = host
        {
            let ipAddr = ipv4Addr.rawValue.withUnsafeBytes { $0.load(as: UInt32.self) }
            print("Got IP address: \(ipAddr):\(port)")
        }

    }

    private func endpointSelected(_ endpoint: NWEndpoint) {
        let connection = NWConnection(to: endpoint, using: .tcp)
        connection.stateUpdateHandler = { [weak self] in
            if case .ready = $0 {
                self?.onConnectionReady(connection)
                connection.cancel()
            }
        }
        connection.start(queue: .global())
    }
}

extension NWConnection.State: RawRepresentable {
    public init?(rawValue: String) {
        return nil
    }

    public var rawValue: String {
        switch self {
        case .cancelled:
            return "cancelled"
        case .failed(let err):
            return "failed: \(err.localizedDescription)"
        case .preparing:
            return "preparing"
        case .ready:
            return "ready"
        case .setup:
            return "setup"
        case .waiting(let err):
            return "waiting: \(err.localizedDescription)"
        @unknown default:
            return ""
        }
    }
}
