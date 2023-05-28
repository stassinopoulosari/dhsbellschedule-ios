//
//  BSPersistence.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSPersistence {
    static let customSymbolsKey = "bs3-persistence-symbolsConfiguration";
    static let symbolTableKey = "bs3-persistence-symbols";
    static let scheduleTableKey = "bs3-persistence-scheduleTable";
    static let calendarKey = "bs3-persistence-calendar";
    static let lastUpdatedKey = "bs3-persistance-lastUpdated";
    static let lastVersionUsedKey = "bs3-compatibilityLastVersionUsed";
    static let firstTimeUserKey = "bs3-firstTimeUser3.0.0-debug1";

    
    public static var contextLastUpdated: Date? {
        if let defaults = defaults {
            let lastUpdatedInterval = defaults.double(forKey: BSPersistence.lastUpdatedKey)
            return Date(timeIntervalSince1970: lastUpdatedInterval)
        } else {
            return nil;
        }
    }
    static let defaults: UserDefaults? = UserDefaults.init(suiteName: "group.com.Stassinopoulos.ari.bellGroup");
    
    public static func save(hardUpdateOfContext context: BSContext) {
        if let defaults = defaults {
            let lastUpdatedInterval = Date.now.timeIntervalSince1970;
            defaults.set(lastUpdatedInterval, forKey: lastUpdatedKey);
            let calendar = context.calendar;
            let symbolTable = context.symbolTable;
            if let calendarExportable = calendar.export(),
               let symbolTableExportable = symbolTable.export()
            {
                save(calendarString: calendarExportable.calendarString, toDefaults: defaults);
                save(scheduleTableString: calendarExportable.scheduleTableString, toDefaults: defaults);
                save(symbolTableString: symbolTableExportable.symbolTableString, toDefaults: defaults);
//                save(customSymbolsString: symbolTableExportable.symbolTableString, toDefaults: defaults)
            }
            
        }
    }
    
    public static func firstTimeUser() -> Bool {
        if let defaults = defaults {
            let firstTimeUser = !defaults.bool(forKey: firstTimeUserKey)
            if firstTimeUser {
                defaults.set(true, forKey: firstTimeUserKey);
            }
            return firstTimeUser;
        }
        return true;
    }
    
    public static func save(softUpdateOfContext context: BSContext) {
        if let defaults = defaults {
            if let symbolTableExportable = context.symbolTable.export() {
//                print(symbolTableExportable.customSymbolsString)
                save(customSymbolsString: symbolTableExportable.customSymbolsString, toDefaults: defaults);
            }
        }
    }
    
    private static func save(calendarString: String, toDefaults defaults: UserDefaults) {
        defaults.set(calendarString, forKey: calendarKey);
    }
    
    private static func save(symbolTableString: String, toDefaults defaults: UserDefaults) {
        defaults.set(symbolTableString, forKey: symbolTableKey);
    }
    
    private static func save(scheduleTableString: String, toDefaults defaults: UserDefaults) {
        defaults.set(scheduleTableString, forKey: scheduleTableKey);
    }
    
    private static func save(customSymbolsString: String, toDefaults defaults: UserDefaults) {
        defaults.set(customSymbolsString, forKey: customSymbolsKey);
    }
    
    private static func loadCalendar(fromDefaults defaults: UserDefaults) -> BSCalendar? {
        if let scheduleTable = loadScheduleTable(fromDefaults: defaults) {
//            print("calendar string \(defaults.string(forKey: calendarKey))")
            if let calendarString = defaults.string(forKey: calendarKey) {
//                print("calendar string \(calendarString)")
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
    private static func loadScheduleTable(fromDefaults defaults: UserDefaults) -> BSScheduleTable? {
//        print("schedule table string \(defaults.string(forKey: scheduleTableKey))")
        if let scheduleTableString = defaults.string(forKey: scheduleTableKey) {
            return BSScheduleTable.from(string: scheduleTableString);
        } else {
            return nil;
        }
    }
    private static func loadSymbolTable(fromDefaults defaults: UserDefaults) -> BSSymbolTable? {
        if let symbolTableString = defaults.string(forKey: symbolTableKey),
           var symbolTable = BSSymbolTable.from(string: symbolTableString) {
            // Load custom symbols
            if let customSymbols = loadCustomSymbols() {
                print(customSymbols)
                symbolTable.register(customSymbols: customSymbols)
            }
            return symbolTable;
        } else {
            return nil;
        }
    }
    private static func loadCustomSymbols(fromDefaults defaults: UserDefaults) -> [String: String] {
        var customSymbolsDictionary = [String: String]();
        do {
            if let customSymbolsString = defaults.string(forKey: customSymbolsKey),
               let customSymbolsData = customSymbolsString.data(using: .utf8),
               let customSymbolsObject = try JSONSerialization.jsonObject(with: customSymbolsData) as? [String: Any]
            {
                customSymbolsObject.forEach { (customSymbolKey, customSymbolValueObject) in
                    if let customSymbolValue = customSymbolValueObject as? String {
                        customSymbolsDictionary[customSymbolKey] = customSymbolValue;
                    }
                }
            }
        } catch {
            print(error);
        }
        return customSymbolsDictionary;
    }
    
    public static func loadCustomSymbols() -> [String: String]? {
        if let defaults = defaults {
            return loadCustomSymbols(fromDefaults: defaults);
        }
        return nil;
    }
    
    public static func loadContext() -> BSContext? {
        if let defaults = defaults {
            // Load calendar
            let loadedCalendar = loadCalendar(fromDefaults: defaults);
//            print("Loaded calendar \(loadedCalendar)");
            // Load symbols
            let loadedSymbolTable = loadSymbolTable(fromDefaults: defaults)
//            print("Loaded symbol table \(loadedSymbolTable)");
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

