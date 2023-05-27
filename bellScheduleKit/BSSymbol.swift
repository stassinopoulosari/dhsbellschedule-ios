//
//  BSSymbol.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSSymbol {
    public var key: String;
    public var defaultValue: String;
    public var configurable: Bool;
    public var configuredValue: String?;
    public var value: String {
        if configurable, let configuredValue = configuredValue {
            return configuredValue;
        }
        return defaultValue;
    }
    func render(templateString: String) -> String {
        return templateString.replacingOccurrences(of: "$(\(key)", with: value);
    }
}

public struct BSSymbolTable {
    public var symbolsDict: [String: BSSymbol];
    private var symbols: [BSSymbol] {
        return Array(symbolsDict.values);
    }
    public func render(templateString: String) {
        var renderedString = templateString;
        symbols.forEach { symbol in
            renderedString = symbol.render(templateString: renderedString);
        }
    }
    
    public static func from(dictionary symbolTableDictionary: [String: Any]) -> BSSymbolTable {
        var symbols = [String: BSSymbol]();
        symbolTableDictionary.forEach { (key: String, symbolObject: Any) in
            if let symbolDictionary = symbolObject as? [String: Any],
               let configurable = symbolDictionary["configurable"] as? Bool,
               let value = symbolDictionary["value"] as? String
            {
                symbols[key] = BSSymbol(key: key, defaultValue: value, configurable: configurable);
            }
        }
        return BSSymbolTable(symbolsDict: symbols);
    }
    
    public static func from(string symbolTableString: String) -> BSSymbolTable? {
        do {
            if let symbolTableDictionary = try JSONSerialization.jsonObject(with: symbolTableString.data(using: .utf8)!) as? [String: Any] {
                return BSSymbolTable.from(dictionary: symbolTableDictionary);
            } else {
                return nil;
            }
        } catch {
            return nil;
        }
    }
}
