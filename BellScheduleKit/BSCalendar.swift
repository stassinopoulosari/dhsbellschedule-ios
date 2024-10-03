//
//  BSCalendar.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSCalendar {
    public struct BSCalendarExportable {
        public var scheduleTableString: String;
        public var calendarString: String;
        public static func from(calendar: BSCalendar) -> BSCalendarExportable? {
            do {
                var calendarObject = [String: [String: [String]]]();
                calendar.calendar.forEach { (key: String, scheduleKey: String) in
                    let keyComponents = key.split(separator: "/");
                    let year = String(keyComponents[0]);
                    let month = String(keyComponents[1]);
                    let index = Int(keyComponents[2]);
                    if (!calendarObject.keys.contains(year)) {
                        calendarObject[year] = [String:[String]]();
                    }
                    if (!calendarObject[year]!.keys.contains(month)) {
                        calendarObject[year]![month] = (0...31).map{_ in ""};
                    }
                    if let index = index {
                        calendarObject[year]![month]![index] = scheduleKey;
                    }
                }
                var calendarRepresentation = [String: [String: String]]();
                calendarObject.forEach { (year: String, value: [String : [String]]) in
                    value.forEach { (month: String, value: [String]) in
                        if(!calendarRepresentation.keys.contains(year)) {
                            calendarRepresentation[year] = [String: String]();
                        }
                        calendarRepresentation[year]![month] = value.joined(separator: ",");
                    }
                }
                //                print(calendarRepresentation);
                if let calendarString = String(data:try JSONSerialization.data(withJSONObject: calendarRepresentation), encoding: .utf8),
                   let scheduleTableString = calendar.scheduleTable.toString() {
                    return BSCalendarExportable(scheduleTableString: scheduleTableString, calendarString: calendarString);
                } else {
                    return nil;
                }
            } catch {
                return nil;
            }
        }
    }
    
    public var scheduleTable: BSScheduleTable;
    public var calendar: [String: String];
    
    public func monthSchedule(forDate date: Date) -> [Int: String]? {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "YYYY/MM"
        let dateString = dateFormatter.string(from: date)
        var returnValue = [Int:String]();
        calendar.enumerated().filter { element in
            return element.element.key.starts(with: dateString)
        }.sorted { element0, element1 in
            if let element0day = Int(element0.element.key.split(separator: "/")[2]),
               let element1day = Int(element1.element.key.split(separator: "/")[2]) {
                return element1day > element0day;
            } else {
                return false;
            }
        }.map { element in
            return (Int(element.element.key.split(separator:"/")[2]), element.element.value);
        }.forEach {element in
            if let key = element.0 {
                returnValue[key] = element.1;
            }
        }
        return returnValue;
    }
    
    public func currentSchedule(forDate date: Date) -> BSSchedule? {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "YYYY/MM/d"
        let dateString = dateFormatter.string(from: date)
        if let scheduleKey = calendar[dateString],
           let schedule = scheduleTable.schedules[scheduleKey] {
            return schedule;
        }
        
        return nil;
    }
    
    public var currentSchedule: BSSchedule? {
        return currentSchedule(forDate: Date.now)
    };
    
    public func export() -> BSCalendarExportable? {
        return BSCalendarExportable.from(calendar: self);
    }
    
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
                                //                                print("component");
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

