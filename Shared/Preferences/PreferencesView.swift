//
//  PreferencesView.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/23/22.
//

import Combine
import Network
import SwiftUI

public struct PreferencesView: View {
    @StateObject var viewModel: PreferencesViewModel

    @State private var isSearching = false

    private let networkDiscoveryView: NetworkDiscoveryView

    init(preferenceServices: PreferenceServices,
         networkDiscoveryView: NetworkDiscoveryView) {
        _viewModel =
            StateObject(wrappedValue: PreferencesViewModel(preferenceServices: preferenceServices))
        self.networkDiscoveryView = networkDiscoveryView
    }

    public var body: some View {
        ZStack {
            VStack {
                TextField("Host", text: $viewModel.internalHost) {
                    if !$0 {
                        print("Lost focus")
                    }
                }
                HStack {
                    Spacer()
                    Button(isSearching ? "Searching..." : "Validate") {
//                        isSearching = true
//                        networkServices
//                            .listenForHomeAssistantInstances()
//                            .sink(receiveCompletion: { _ in
//                                self.isSearching = false
//                            }, receiveValue: {
//                                self.discoveredHosts.append($0)
//                            })
//                            .store(in: &self.subscriptions)
                    }
                    Button("Save") {
                        viewModel.savePreferences()
                    }
                }
                HStack {
                    networkDiscoveryView
                }
            }
        }
    }
}

public protocol PreferenceServices {
    func validateInternalHost(_ internalHost: String) -> Bool

    func savePreferences(_ preferencesModel: PreferencesModel)

    func getPreferences() -> PreferencesModel
}

public struct PreferencesModel: Codable {
    var internalHost: URL?
}

struct PreferencesView_Previews: PreviewProvider {
    class MockPreferenceServices: PreferenceServices {
        private var prefModel = PreferencesModel()

        func validateInternalHost(_: String) -> Bool {
            true
        }

        func getPreferences() -> PreferencesModel {
            prefModel
        }

        func savePreferences(_ preferencesModel: PreferencesModel) {
            prefModel = preferencesModel
        }
    }

    static var previews: some View {
        Group {
            PreferencesView(preferenceServices: MockPreferenceServices(),
                            networkDiscoveryView: NetworkDiscoveryView(networkBrowserServices: NetworkBrowserServicesImpl()))
        }
    }
}
