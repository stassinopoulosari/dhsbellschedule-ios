//
//  BSCompatibility.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-26.
//

import Foundation

public struct BSCompatibility {
    
    /// Convert previous defaults from UBSA to the new Bell Schedule
    public static func convert() {
        let jsonEncoder = JSONEncoder();
        if let defaults = BSPersistence.defaults {
            // Check for key lastVersionUsed
            if let lastVersionUsed = defaults.string(forKey: BSPersistence.lastVersionUsedKey) {
                if(lastVersionUsed == "3.0.0" || lastVersionUsed == "3.1.0") {
                    return;
                }
            } else {
                print("Converting")
                // Convert symbols
                // Get all keys
                let keys = defaults.dictionaryRepresentation().keys;
                var newSymbols = [String: String]();
                keys.forEach { key in
                    // Convert individual symbol
                    if let symbolValue = defaults.string(forKey: key) {
                        newSymbols[key] = symbolValue;
                        // Delete symbol
                        defaults.set(nil, forKey: key);
                    }
                }
                // Save new keys
                do {
                    let encodedSymbols = try jsonEncoder.encode(newSymbols)
                    defaults.set(encodedSymbols, forKey: BSPersistence.customSymbolsKey);
                    defaults.set("3.1.0", forKey: BSPersistence.lastVersionUsedKey);
                } catch {
                    print("Unable to encode new symbols: \(error)");
                }
            }
        } else {
            print("Unable to create defaults.");
        }
    }
}

