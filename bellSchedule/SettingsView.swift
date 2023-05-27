//
//  SettingsView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import Foundation
import SwiftUI
import BellScheduleKit

enum Setting {
    case editClassNames
    case about
    case sendFeedback
}

struct SettingsView: View {
    //    @Binding var settingsShown: Bool;
    
    public var context: BSContext;
    
    public init(context: BSContext) {
        self.context = context
    }
    
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
                    EditClassNamesView(symbolTable: context.symbolTable)
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
    @State public var symbol: BSSymbol;
    
    var body: some View {
        TextField(symbol.defaultValue, text: $symbol.configuredValue)
    }
    
}

struct EditClassNamesView: View {
    public var symbolTable: BSSymbolTable;
    private var symbols: [BSSymbol] {
        return symbolTable.symbolsDict.values.filter { symbol in
            return symbol.configurable;
        }
    }
    var body: some View {
        List(symbols, id: \.self) {
            symbol in
            SymbolEditTextField(symbol: symbol)
        }
    }
}
