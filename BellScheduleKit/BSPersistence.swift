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
    static let firstTimeUserKey = "bs3-firstTimeUser3.1.0";
    static let notificationsOnKey = "bs3-notificationsOn";
    static let notificationsIntervalKey = "bs3-notificationsInterval";
    static let skipZeroPeriodNotificationsKey = "bs3-skipZeroPeriodNotifications";
    static let zeroPeriodSymbolKey = "bs3-zeroPeriodSymbol";
    
    /// Date the saved context was last updated
    public static var contextLastUpdated: Date? {
        if let defaults = defaults {
            let lastUpdatedInterval = defaults.double(forKey: BSPersistence.lastUpdatedKey)
            print(Date(timeIntervalSince1970: lastUpdatedInterval))
            return Date(timeIntervalSince1970: lastUpdatedInterval)
        } else {
            return nil;
        }
    }
    
    /// The defaults we are using for persistence
    static let defaults: UserDefaults? = UserDefaults(suiteName: "group.com.Stassinopoulos.ari.bellGroup");
    
    /// Representation of Notification Settings
    public struct NotificationsSettings {
        public var notificationsOn: Bool;
        public var skipZeroPeriod: Bool;
        public var notificationsInterval: Double;
    }
    
    /// Load the user's notification settings
    /// - Returns: the user's notification settings, or the default settings if none are saved
    public static func loadUserNotificationsSettings() -> NotificationsSettings {
        if let defaults = defaults
           {
            let notificationsOn = defaults.bool(forKey: notificationsOnKey)
            let notificationsInterval = defaults.double(forKey: notificationsIntervalKey);
            let skipZeroPeriod = defaults.bool(forKey: skipZeroPeriodNotificationsKey);
            if(notificationsInterval == 0) {
                return NotificationsSettings(notificationsOn: false, skipZeroPeriod: false, notificationsInterval: 5.0)
            }
            return NotificationsSettings(notificationsOn: notificationsOn, skipZeroPeriod: skipZeroPeriod, notificationsInterval: notificationsInterval)
        }
        return NotificationsSettings(notificationsOn: false, skipZeroPeriod: false, notificationsInterval: 5.0);
    }
    
    /// Save the user's notification settings
    /// - Parameter userNotificationSettings: The user's notification settings to save
    public static func save(userNotificationsSettings notificationsSettings: NotificationsSettings) {
        if let defaults = defaults {
            let notificationsOn = notificationsSettings.notificationsOn;
            let notificationsInterval = notificationsSettings.notificationsInterval;
            let skipZeroPeriod = notificationsSettings.skipZeroPeriod;
            defaults.set(notificationsOn, forKey: notificationsOnKey);
            defaults.set(notificationsInterval, forKey: notificationsIntervalKey);
            defaults.set(skipZeroPeriod, forKey: skipZeroPeriodNotificationsKey);
        }
    }
    
    /// Save a hard update of the context from the network
    /// - Parameter context: The context with the user's new settings
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
                save(zeroPeriodSymbol: context.zeroPeriodSymbol, toDefaults: defaults)
            }
            
        }
    }
    
    /// - Returns: `true` if the user has not opened up the mobile app before
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
    
    /// Save an update of the custom symbols string
    /// - Parameter contextWithUpdatedCustomSymbols: The context with custom symbols
    public static func save(contextWithUpdatedCustomSymbols context: BSContext) {
        if let defaults = defaults {
            if let symbolTableExportable = context.symbolTable.export() {
                save(customSymbolsString: symbolTableExportable.customSymbolsString, toDefaults: defaults);
            }
        }
    }
    
    /// Save the calendar string (used internally)
    /// - Parameter calendarString: The content to save
    /// - Parameter toDefaults: the defaults to which we are saving
    private static func save(calendarString: String, toDefaults defaults: UserDefaults) {
        defaults.set(calendarString, forKey: calendarKey);
    }
    
    /// Save the symbol table string (used internally)
    /// - Parameter symbolTableString: The content to save
    /// - Parameter toDefaults: the defaults to which we are saving
    private static func save(symbolTableString: String, toDefaults defaults: UserDefaults) {
        defaults.set(symbolTableString, forKey: symbolTableKey);
    }
    
    /// Save the schedule table string (used internally)
    /// - Parameter symbolTableString: The content to save
    /// - Parameter toDefaults: the defaults to which we are saving
    private static func save(scheduleTableString: String, toDefaults defaults: UserDefaults) {
        defaults.set(scheduleTableString, forKey: scheduleTableKey);
    }
    
    /// Save the custom symbols string (used internally)
    /// - Parameter symbolTableString: The content to save
    /// - Parameter toDefaults: the defaults to which we are saving
    private static func save(customSymbolsString: String, toDefaults defaults: UserDefaults) {
        defaults.set(customSymbolsString, forKey: customSymbolsKey);
    }
    
    /// Save the zero period symbol (used internally)
    /// - Parameter symbolTableString: The content to save
    /// - Parameter toDefaults: the defaults to which we are saving
    private static func save(zeroPeriodSymbol: String, toDefaults defaults: UserDefaults) {
        defaults.set(zeroPeriodSymbol, forKey: zeroPeriodSymbolKey);
    }
    
    /// Load the calendar from the defaults (used internally)
    /// - Parameter fromDefaults: the defaults from which we are loading
    /// - Returns: nil if no calendar exists in the defaults, otherwise the saved calendar
    private static func loadCalendar(fromDefaults defaults: UserDefaults) -> BSCalendar? {
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
    
    /// Load the schedule table from the defaults (used internally)
    /// - Parameter fromDefaults: the defaults from which we are loading
    /// - Returns: nil if no schedule table exists in the defaults, otherwise the saved schedule table
    private static func loadScheduleTable(fromDefaults defaults: UserDefaults) -> BSScheduleTable? {
        if let scheduleTableString = defaults.string(forKey: scheduleTableKey) {
            return BSScheduleTable.from(string: scheduleTableString);
        } else {
            return nil;
        }
    }
    
    /// Load the symbol table from the defaults (used internally)
    /// - Parameter fromDefaults: the defaults from which we are loading
    /// - Returns: nil if no symbol table exists in the defaults, otherwise the saved symbol table
    private static func loadSymbolTable(fromDefaults defaults: UserDefaults) -> BSSymbolTable? {
        if let symbolTableString = defaults.string(forKey: symbolTableKey),
           var symbolTable = BSSymbolTable.from(string: symbolTableString) {
            // Load custom symbols
            if let customSymbols = loadCustomSymbols() {
                symbolTable.register(customSymbols: customSymbols)
            }
            return symbolTable;
        } else {
            return nil;
        }
    }
    
    /// Load the custom symbols from the defaults (used internally)
    /// - Parameter fromDefaults: the defaults from which we are loading
    /// - Returns: nil if no custom symbols exist in the defaults, otherwise the custom symbols
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
    
    /// Load the zero period symbol from the defaults (used internally)
    /// - Parameter fromDefaults: the defaults from which we are loading
    /// - Returns: nil if no zero period symbol exists in the defaults, otherwise the saved zero period symbol
    private static func loadZeroPeriodSymbol(fromDefaults defaults: UserDefaults) -> String? {
        if let zeroPeriodSymbol = defaults.string(forKey: zeroPeriodSymbolKey) {
            return zeroPeriodSymbol;
        }
        return nil;
    }
    
    /// Load custom symbols
    /// - Returns: A `[String:String]` with the custom symbols if they exist, otherwise `nil`.
    public static func loadCustomSymbols() -> [String: String]? {
        if let defaults = defaults {
            return loadCustomSymbols(fromDefaults: defaults);
        }
        return nil;
    }
    
    /// Load zero period symbol
    /// - Returns: A `String` with the zero period symbol if it exists, otherwise `nil`.
    public static func loadZeroPeriodSymbol() -> String? {
        if let defaults = defaults {
            return loadZeroPeriodSymbol(fromDefaults: defaults);
        }
        return nil;
    }
    
    /// Load context
    /// - Returns: The saved `BSContext` if it exists
   public static func loadContext() -> BSContext? {
        if let defaults = defaults {
            // Load calendar
            let loadedCalendar = loadCalendar(fromDefaults: defaults);
            // Load symbols
            let loadedSymbolTable = loadSymbolTable(fromDefaults: defaults)
            let loadedZeroPeriodSymbol = loadZeroPeriodSymbol(fromDefaults: defaults)
            // Load custom symbols
            if let calendar = loadedCalendar,
               let symbolTable = loadedSymbolTable,
               let lastUpdated = contextLastUpdated,
               let zeroPeriodSymbol = loadedZeroPeriodSymbol{
                return BSContext(calendar: calendar, symbolTable: symbolTable, origin: .cache, lastUpdated: lastUpdated, zeroPeriodSymbol: zeroPeriodSymbol)
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

