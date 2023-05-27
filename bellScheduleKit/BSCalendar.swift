//
//  BSCalendar.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSCalendar {
    public var scheduleTable: BSScheduleTable;
    public var calendar: [String: String];
    
    public static func from(dictionary calendarDictionary: [String: Any], withScheduleTable scheduleTable: BSScheduleTable) -> BSCalendar {
        var calendar = [String: String]();
        calendarDictionary.forEach { (year: String, yearObject: Any) in
            if year != "bounds",
               let yearDictionary = yearObject as? [String: Any] {
                yearDictionary.forEach { (month: String, monthObject: Any) in
                    if let monthString = monthObject as? String {
                        let monthStringComponents = monthString.split(separator: ",", omittingEmptySubsequences: false);
                        monthStringComponents.enumerated().forEach { (index, component) in
                            if (component != "" && scheduleTable.schedules.keys.contains(String(component))) {
                                calendar["\(year)/\(month)/\(index)"] = String(component);
                            }
                        }
                    }
                }
            }
        }
        return BSCalendar(scheduleTable: scheduleTable, calendar: calendar);
    }
    
    public static func from(string calendarString: String, withScheduleTable scheduleTable:BSScheduleTable) -> BSCalendar? {
        do {
            if let calendarDictionary = try JSONSerialization.jsonObject(with: calendarString.data(using: .utf8)!) as? [String: Any] {
                return BSCalendar.from(dictionary: calendarDictionary, withScheduleTable: scheduleTable)
            } else {
                return nil;
            }
        } catch {
            return nil;
        }
    }
}
