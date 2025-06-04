//
//  SettingsSymbols.swift
//  BellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-29.
//

import Foundation
import SwiftUI
import BellScheduleKit
import WidgetKit

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
                    Notifications(context: context, settings: BSPersistence.loadUserNotificationsSettings()).scheduleNotifications();
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        )
        TextField(context.symbolTable.symbolsDict[key]!.defaultValue, text: configuredValue).onAppear {
            UITextField.appearance().clearButtonMode = .whileEditing;
        }
        .accessibilityHint("\(context.symbolTable.symbolsDict[key]!.defaultValue) \(context.symbolTable.symbolsDict[key]!.isConfigured ? "is labeled \(context.symbolTable.symbolsDict[key]!.configuredValue)" : "is not labeled")");
    }
    
}

struct SettingsSymbolsView: View {
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
        List {
            Section(footer: Text("All changes are saved automatically.")) {
                ForEach(symbols, id: \.self) {
                    symbol in
                    SymbolEditTextField(context: context, key: symbol)
                }
                .accessibilityElement(children: .contain)
            }
            .accessibilityElement(children: .contain)
        }
        .accessibilityLabel("Custom symbol configuration")
        .listStyle(.grouped)
        .accessibilityElement(children: .contain)
    }
}
