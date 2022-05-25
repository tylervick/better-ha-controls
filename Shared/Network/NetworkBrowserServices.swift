//
//  NetworkBrowserServices.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/24/22.
//

import Combine
import Foundation
import Network

public protocol NetworkBrowserServices {
    func listenForHomeAssistantInstances() -> AnyPublisher<NWBrowser.Result.Change, Never>

    func cancel()
}

public class NetworkBrowserServicesImpl: NetworkBrowserServices {
    let browser: NWBrowser

    private let haSubject = PassthroughSubject<NWBrowser.Result.Change, Never>()

    init() {
        let params = NWParameters()
        params.includePeerToPeer = true
        browser = NWBrowser(for: .bonjour(type: "_home-assistant._tcp", domain: nil), using: params)
        browser.browseResultsChangedHandler = browseResultsChanged
    }

    public func listenForHomeAssistantInstances() -> AnyPublisher<NWBrowser.Result.Change, Never> {
        browser.start(queue: DispatchQueue.global())

        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.cancel()
        }

        return haSubject.eraseToAnyPublisher()
    }

    public func cancel() {
        browser.cancel()
        haSubject.send(completion: .finished)
    }

    private func browseResultsChanged(_: Set<NWBrowser.Result>,
                                      _ changes: Set<NWBrowser.Result.Change>) {
        changes.forEach(haSubject.send)
    }
}

extension NWEndpoint: Identifiable {
    public var id: String {
        switch self {
        case let .hostPort(host, port):
            return "\(host):\(port)"
        case let .service(name, type, domain, interface):
            return "\(name)-\(type)-\(domain)-\(interface)"
        case let .unix(path):
            return path
        case let .url(url):
            return "\(url.absoluteString)"
        @unknown default:
            return "unknown"
        }
    }
}
