//
//  NetworkDiscoveryView.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/23/22.
//

import SwiftUI
import Combine
import Network

public struct NetworkDiscoveryView: View {
    @StateObject var viewModel: NetworkDiscoveryViewModel

    init(networkBrowserServices: NetworkBrowserServices) {
        _viewModel =
            StateObject(wrappedValue: NetworkDiscoveryViewModel(networkBrowserServices: networkBrowserServices))
    }

    public var body: some View {
        HStack {
            Menu("Discovered Hosts...") {
                Button("Loading...", action: {
                    viewModel.startHostDiscovery()
                    
                })
//                    .disabled(true)
                    .onAppear {
                        print("Appeared!")
                        viewModel.startHostDiscovery()
                    }
                ForEach(Array(viewModel.networkEndpoints), id: \.id) { endpoint in
                    Button(endpoint.name) {
//                        viewModel.discoveryCancellable?.cancel()
                    }
                }
            }.onTapGesture {
                print("Tapped!")
            }
            .onAppear {
                print("menu appeared!")
            }

            Button("Search") {
                viewModel.startHostDiscovery()
            }
//            List(Array(viewModel.networkEndpoints), id: \.id) { endpoint in
//                Text(endpoint.name)
//            }

        }
    }
}

struct NetworkDiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkDiscoveryView(networkBrowserServices: NetworkBrowserServicesImpl())
    }
}
