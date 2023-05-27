//
//  BSPersistence.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSPersistence {
    let customSymbolsKey = "bs3-persistence-symbolsConfiguration";
    let symbolTableKey = "bs3-persistence-symbols";
    let scheduleTableKey = "bs3-persistence-scheduleTable";
    let calendarKey = "bs3-persistence-calendar";
    let lastUpdatedKey = "bs3-persistance-lastUpdated";
    let lastVersionUsedKey = "bs3-compatibilityLastVersionUsed";
    
    public var contextLastUpdated: Date? {
        if let defaults = BSPersistence.defaults, let lastUpdatedString = defaults.string(forKey: lastUpdatedKey) {
            let dateFormatter = DateFormatter();
            return dateFormatter.date(from: lastUpdatedString);
        } else {
            return nil;
        }
    }
    static let defaults: UserDefaults? = UserDefaults.init(suiteName: "group.com.Stassinopoulos.ari.bellGroup");
    
    func save(context: BSContext, softUpdate: Bool = false) {
        if let defaults = BSPersistence.defaults {
            if(!softUpdate) {
                let dateFormatter = DateFormatter();
                let lastUpdated = Date();
                defaults.set(dateFormatter.string(from: lastUpdated), forKey: lastUpdatedKey);
            }
        }
    }
    
    private func loadCalendar(fromDefaults defaults: UserDefaults) -> BSCalendar? {
        if let scheduleTable = loadScheduleTable(fromDefaults: defaults) {
            if let calendarString = defaults.string(forKey: calendarKey) {
                return BSCalendar.from(string: calendarString, withScheduleTable: scheduleTable)
            } else {
                // Could not load calendar
                return nil;
            }
        } else {
            // Could not load schedule
            return nil;
        }
    }
    private func loadScheduleTable(fromDefaults defaults: UserDefaults) -> BSScheduleTable? {
        if let scheduleTableString = defaults.string(forKey: scheduleTableKey) {
            return BSScheduleTable.from(string: scheduleTableString);
        } else {
            return nil;
        }
    }
    private func loadSymbolTable(fromDefaults defaults: UserDefaults) -> BSSymbolTable? {
        if let symbolTableString = defaults.string(forKey: symbolTableKey),
           var symbolTable = BSSymbolTable.from(string: symbolTableString) {
            // Load custom symbols
            do {
                if let customSymbolsString = defaults.string(forKey: customSymbolsKey),
                   let customSymbolsData = customSymbolsString.data(using: .utf8),
                   let customSymbolsObject = try JSONSerialization.jsonObject(with: customSymbolsData) as? [String: Any]
                {
                    customSymbolsObject.forEach { (customSymbolKey, customSymbolValueObject) in
                        if symbolTable.symbolsDict.keys.contains(customSymbolKey),
                           symbolTable.symbolsDict[customSymbolsKey]!.configurable,
                           let customSymbolValue = customSymbolValueObject as? String
                        {
                            symbolTable.symbolsDict[customSymbolKey]?.configuredValue = customSymbolValue
                        }
                    }
                }
            } catch {
                print(error);
            }
            return symbolTable;
        } else {
            return nil;
        }
    }
    
    public func load() -> BSContext? {
        if let defaults = BSPersistence.defaults {
            // Load calendar
            let loadedCalendar = loadCalendar(fromDefaults: defaults);
            // Load symbols
            let loadedSymbolTable = loadSymbolTable(fromDefaults: defaults)
            // Load custom symbols
            if let calendar = loadedCalendar,
               let symbolTable = loadedSymbolTable,
               let lastUpdated = contextLastUpdated{
                return BSContext(calendar: calendar, symbolTable: symbolTable, type: .cache, lastUpdated: lastUpdated)
            } else {
                // Incomplete data
                return nil
            }
        } else {
            // Could not get defaults
            return nil
        }
    }
}
