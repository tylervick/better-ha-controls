//
//  PreferencesView.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/15/22.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct PreferencesView: View {

    let vm = SignInViewModel()
    
    @State var ipAddr: String = "http://homeassistant.local:8123"

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Home Assistant URL:")
                TextField(
                    "http://homeassistant.local:8123",
                    text: $ipAddr
                ) {
                    print("COMMITTED!")
                    startAuthFlow()
                }

            }.padding()
            Spacer()
            HStack {
                Spacer()
                Button("Authenticate") {
                    print("Started auth!")
                }.padding()
            }
        }
        .frame(width: 400, height: 600)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                serveOAuthCallback()
            }
        }
    }

    
    func startAuthFlow() {
        var components = URLComponents(string: ipAddr)
        components?.path = "/auth/authorize"
        components?.queryItems = [
            "response_type": "code",
            "client_id": "http://10.0.1.68:4000",
            "redirect_uri": "betterha://auth"
        ].map { URLQueryItem(name: $0, value: $1) }

        let scheme = "betterha"

        guard let url = components?.url else { return }

        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { callbackUrl, error in
            print(callbackUrl)
            print(error)
        }
        session.presentationContextProvider = vm
        session.start()
    }
    
}

class SignInViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}

struct PreferencesView_Previews: PreviewProvider {

    static var previews: some View {
        PreferencesView()
    }

}
