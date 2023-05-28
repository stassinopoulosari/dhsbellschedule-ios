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
                    EditClassNamesView(context: context)
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
    @ObservedObject public var context: BSContext;
    @State public var key: String;
    
    var body: some View {
        let configuredValue = Binding(
            get: { () -> String in
                if let symbol = context.symbolTable.symbolsDict[key] {
                    return symbol.configuredValue;
                }
                return "";
            },
            set: { value in
                if context.symbolTable.symbolsDict[key] != nil {
                    context.symbolTable.symbolsDict[key]?.configuredValue = value;
                    context.saveCustomSchedules();
                }
            }
        )
        TextField(context.symbolTable.symbolsDict[key]!.defaultValue, text: configuredValue);
    }
    
}

struct EditClassNamesView: View {
    @ObservedObject public var context: BSContext;
    private var symbols: [String] {
        return Array(
            context.symbolTable.symbolsDict.filter { key, symbol in
                return symbol.configurable;
            }.keys.sorted(by: { key1, key2 in
                return context.symbolTable.symbolsDict[key1]!.defaultValue < context.symbolTable.symbolsDict[key2]!.defaultValue
            })
        )
    }
    var body: some View {
        List(symbols, id: \.self) {
            symbol in
            SymbolEditTextField(context: context, key: symbol)
        }
    }
}
