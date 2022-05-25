//
//  PreferencesViewModel.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/23/22.
//

import Combine
import Foundation

class PreferencesViewModel: ObservableObject {
    @Published var internalHost: String
    @Published var internalHostIsValid: Bool?

    private let preferenceServices: PreferenceServices

    init(preferenceServices: PreferenceServices) {
        self.preferenceServices = preferenceServices
        let initialState = preferenceServices.getPreferences()
        internalHost = initialState.internalHost?.absoluteString ?? ""
    }

    func savePreferences() {
        let preferencesModel = PreferencesModel(internalHost: URL(string: internalHost))
        preferenceServices.savePreferences(preferencesModel)
    }
}
