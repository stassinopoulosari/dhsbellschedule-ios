//
//  SettingsView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import Foundation
import SwiftUI

enum Setting {
    case editClassNames
    case about
    case sendFeedback
}

struct SettingsView: View {
    //    @Binding var settingsShown: Bool;
    
    private var settings: [Setting] = [
        .editClassNames,
        .about,
        .sendFeedback
    ]
    
    var body: some View {
        List(settings, id: \.self) {
            settingsLink in
            
            switch settingsLink {
            case .editClassNames:
                NavigationLink{
                    EditClassNamesView(symbols: [
                        Symbol(defaultValue: "Period 0", symbol: "per0"),
                        Symbol(defaultValue: "Period 1", symbol: "per1"),
                        Symbol(defaultValue: "Period 2", symbol: "per2"),
                        Symbol(defaultValue: "Period 3", symbol: "per3"),
                        Symbol(defaultValue: "Period 4", symbol: "per4")
                    ])
                    .navigationTitle("Edit class names")
                } label: {
                    Text("Edit class names")
                }
            case .about:
                NavigationLink {
                    AboutView()
                        .navigationTitle("About")
                } label: {
                    Text("About")
                }
            case .sendFeedback:
                Button("Send Feedback") {
                    if let formUrl = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSePaLX8E9wJ2GrronsBW4UwzooceSVtUqsdzDkILXOy596Qgg/viewform") {
                        UIApplication.shared.open(formUrl, options:[:], completionHandler: nil);
                    }
                }
            }
        }.listStyle(.plain)
        
    }
}
struct AboutView: View {
    var aboutText = """
This app is an open-source product.

DHS Bell Schedule App 3.0.0 was written in 2023 by Ari Stassinopoulos.

This app is a gift from the Dublin High School class of 2020.

The Bell Schedule App is funded thanks to generous contributions by the Parent-Student-Faculty-Organization (PFSO).

Libraries:

- Firebase
https://firebase.google.com

- UBSAKit
https://github.com/stassinopoulosari/UBSA

Hello from beautiful San Diego, California!
"""
    var body: some View {
        List([""], id: \.self) {
            _ in
            Text(.init(aboutText))
        }
    }
}

struct SymbolEditTextField: View {
    @State var symbol: Symbol;
    
    var body: some View {
        TextField(symbol.defaultValue, text: $symbol.value)
    }
}

struct EditClassNamesView: View {
    @State var symbols: [Symbol]
    var body: some View {
        List(symbols, id: \.self) {
            symbol in
            SymbolEditTextField(symbol: symbol)
        }
    }
}
