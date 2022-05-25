//
//  Better_HA_ControlsApp.swift
//  Shared
//
//  Created by Tyler Vick on 5/15/22.
//

import SwiftUI

@main
struct Better_HA_ControlsApp: App {
    var preferenceServices: PreferenceServices {
        PreferenceServicesImpl()
    }

    var networkBrowserServices: NetworkBrowserServices {
        NetworkBrowserServicesImpl()
    }

    var networkDiscoveryView: NetworkDiscoveryView {
        NetworkDiscoveryView(networkBrowserServices: networkBrowserServices)
    }

    var body: some Scene {
        WindowGroup {
            PreferencesView(preferenceServices: preferenceServices,
                            networkDiscoveryView: networkDiscoveryView)
        }
    }
}

class PreferenceServicesImpl: PreferenceServices {
    func validateInternalHost(_: String) -> Bool {
        true
    }

    func savePreferences(_ preferencesModel: PreferencesModel) {
        print("Saving \(preferencesModel)")
    }

    func getPreferences() -> PreferencesModel {
        PreferencesModel(internalHost: URL(string: "http://10.0.1.100:8123"))
    }
}
