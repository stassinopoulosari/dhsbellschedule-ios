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
    private var realConfiguredValue: String?;
    
    public init(key: String, defaultValue: String, configurable: Bool, realConfiguredValue: String? = nil) {
        self.key = key
        self.defaultValue = defaultValue
        self.configurable = configurable
        self.realConfiguredValue = realConfiguredValue
    }
    
    public var configuredValue: String {
        get {
            if let configuredValue = realConfiguredValue {
                return configuredValue;
            }
            return "";
        }
        set {
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                realConfiguredValue = nil;
            } else {
                realConfiguredValue = newValue;
            }
        }
    };
    public var value: String {
        if configurable, let realConfiguredValue = realConfiguredValue {
            return realConfiguredValue;
        }
        return defaultValue;
    }
    func render(templateString: String) -> String {
        return templateString.replacingOccurrences(of: "$(\(key))", with: value);
    }
}

public struct BSSymbolTable {
    public struct BSSymbolTableExportable {
        public var symbolTableString: String;
        public var customSymbolsString: String;
        
        public static func from(symbolTable: BSSymbolTable) -> BSSymbolTableExportable? {
            var symbolTableObject = [String: Any]();
            symbolTable.symbolsDict.forEach { (key: String, symbol: BSSymbol) in
                var symbolObject = [String: Any]();
                symbolObject["configurable"] = symbol.configurable;
                symbolObject["value"] = symbol.defaultValue;
                symbolTableObject[key] = symbolObject;
            }
            
            var customSymbolsObject = [String: String]();
            symbolTable.symbolsDict.values.filter { symbol in
                symbol.configurable
            }.forEach { symbol in
                if(symbol.configuredValue != "") {
                    customSymbolsObject[symbol.key] = symbol.configuredValue;
                }
            }
            
            do {
                let symbolTableData = try JSONSerialization.data(withJSONObject: symbolTableObject);
                let customSymbolsData = try JSONSerialization.data(withJSONObject: customSymbolsObject);
                if let symbolTableString = String(data: symbolTableData, encoding: .utf8),
                   let customSymbolsString = String(data: customSymbolsData, encoding: .utf8) {
                    return BSSymbolTableExportable(symbolTableString: symbolTableString, customSymbolsString: customSymbolsString)
                } else {
                    return nil;
                }
            } catch {
                return nil;
            }
        }
    }
        
    public func export() -> BSSymbolTableExportable? {
        return BSSymbolTableExportable.from(symbolTable: self);
    }
    
    public var symbolsDict: [String: BSSymbol];
    private var symbols: [BSSymbol] {
        return Array(symbolsDict.values);
    }
    public func render(templateString: String) -> String {
        var renderedString = templateString;
        symbols.forEach { symbol in
            renderedString = symbol.render(templateString: renderedString);
        }
        return renderedString;
    }
    
    mutating public func register(customSymbols: [String: String]) {
        customSymbols.forEach { (customSymbolKey, customSymbolValue) in
            if symbolsDict.keys.contains(customSymbolKey),
               symbolsDict[customSymbolKey]!.configurable
            {
                symbolsDict[customSymbolKey]?.configuredValue = customSymbolValue
            } else {
                print("Tried to register invalid custom symbol: \(customSymbolKey) = \(customSymbolValue)");
            }
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

