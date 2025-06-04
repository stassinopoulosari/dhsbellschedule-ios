//
//  BSSchedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSScheduleTable {
    
    /// Table of schedules by key
    public var schedules: [String: BSSchedule];
    
    /// Allow a schedule to be printed
    /// - Returns: String representation of a schedule
    public func toString() -> String? {
        var scheduleTableObject = [String: [String: Any]]();
        
        schedules.forEach { (key, schedule) in
            var scheduleObject = [String: Any]();
            scheduleObject["name"] = schedule.name;
            schedule.periods.forEach { period in
                var periodObject = [String:Any]();
                periodObject["name"] = period.name;
                periodObject["start"] = period.startTime.string;
                periodObject["end"] = period.endTime.string;
                scheduleObject[period.key] = periodObject;
            }
            scheduleTableObject[key] = scheduleObject;
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: scheduleTableObject)
            if let scheduleTableString = String(data: data, encoding: .utf8) {
                return scheduleTableString;
            } else {
                return nil;
            }
        } catch {
            return nil;
        }
        
        
    }
    
    /// Create a schedule table from a dictionary
    /// - Parameter dictionary: A [String: Any] representation of a schedule
    /// - Returns: A schedule table
    public static func from(dictionary scheduleTableDictionary: [String: Any]) -> BSScheduleTable {
        var schedules = [String: BSSchedule]();
        scheduleTableDictionary.forEach { (key, value) in
            if let scheduleDictionary = value as? [String: Any],
               let schedule = BSSchedule.from(dictionary: scheduleDictionary) {
                schedules[key] = schedule;
            }
        }
        return BSScheduleTable(schedules: schedules);
    }
    
    /// Create a schedule table from a string
    /// - Parameter string: A String/JSON representation of a schedule Table
    /// - Returns: A schedule table if the representation is valid
    public static func from(string scheduleTableString: String) -> BSScheduleTable? {
        do {
            if let scheduleTableDictionary = try JSONSerialization.jsonObject(with: scheduleTableString.data(using: .utf8)!) as? [String: Any] {
                return BSScheduleTable.from(dictionary: scheduleTableDictionary);
            } else {
                return nil;
            }
        } catch {
            return nil;
        }
    }
}

public struct BSSchedule {
    /// Name of the schedule
    public var name: String;
    /// Display name of the schedule
    public var displayName: String {
        return name.replacingOccurrences(of: "![0-9]*( )?", with: "", options: .regularExpression).replacingOccurrences(of: "ZZZ", with: "");
    };
    /// The BSPeriods of a schedule
    public var periods: [BSPeriod];
    
    /// The current Period at this time for a schedule
    public var currentPeriod: BSPeriod? {
        var currentPeriod: BSPeriod? = nil;
        periods.forEach { period in
            if(period.isCurrent) {
                currentPeriod = period;
            }
        }
        return currentPeriod;
    }
    
    /// The current period for a time of a schedule
    /// - Parameter forDate: the Date we are checking the currency of a period for
    /// - Returns: the current Period if one exists, nil otherwise
    public func currentPeriod(forDate date: Date) -> BSPeriod? {
        var currentPeriod: BSPeriod? = nil;
        periods.forEach { period in
            if(period.isCurrent(forDate: date)) {
                currentPeriod = period;
            }
        }
        return currentPeriod;
    }
    
    /// Create a BSSchedule form a Dictionary
    /// - Parameter dictionary: A Dictionary representation of the schedule
    /// - Returns: A BSSchedule if the dictionary is valid
    public static func from(dictionary scheduleObject: [String: Any]) -> BSSchedule? {
        var periods = [BSPeriod]();
        if scheduleObject["hidden"] != nil {
            return nil;
        }
        if let scheduleName = scheduleObject["name"] as? String {
            scheduleObject.keys.sorted().forEach { key in
                if(key == "name") {
                    return;
                }
                
                if let period = scheduleObject[key] as? [String: Any],
                   let startString = period["start"] as? String,
                   let endString = period["end"] as? String,
                   let periodName = period["name"] as? String
                {
                    periods.append(
                        BSPeriod(
                            startTime: BSTime(string: startString),
                            endTime: BSTime(string: endString),
                            name: periodName,
                            key: key
                        )
                    );
                }
            }
            return BSSchedule(name: scheduleName, periods: periods)
        } else {
            return nil;
        }
    }
}

