//
//  NetworkViewModel.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/24/22.
//

import Combine
import Network

class NetworkDiscoveryViewModel: ObservableObject {
    @Published var networkEndpoints: Set<NWEndpoint> = []

    private var discoveryCancellable: AnyCancellable?

    private let networkBrowserServices: NetworkBrowserServices

    init(networkBrowserServices: NetworkBrowserServices) {
        self.networkBrowserServices = networkBrowserServices
    }

    func startHostDiscovery() {
        discoveryCancellable = networkBrowserServices
            .listenForHomeAssistantInstances()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] change in
                switch change {
                case let .added(result):
                    self?.networkEndpoints.insert(result.endpoint)
                case let .removed(result):
                    self?.networkEndpoints.remove(result.endpoint)
                case let .changed(old: _, new: new, flags: _):
                    self?.networkEndpoints.update(with: new.endpoint)
                case .identical:
                    break
                @unknown default:
                    break
                }
            })
    }
}

extension NWEndpoint {
    var name: String {
        switch self {
        case let .hostPort(host, port):
            return "\(host):\(port)"
        case let .service(name, type, domain, interface):
            return name
        case let .unix(path):
            return path
        case let .url(url):
            return url.absoluteString
        @unknown default:
            return ""
        }
    }
}

// extension NetworkDiscoveryViewModel: Subscriber {
//
//    func receive(subscription: Subscription) {
//        subscription.request(.max(10))
//    }
//
//    func receive(_ input: NWBrowser.Result.Change) -> Subscribers.Demand {
//        return .max(10)
//    }
//
//    func receive(completion: Subscribers.Completion<Never>) {
//        print("completed")
//    }
//
// }
