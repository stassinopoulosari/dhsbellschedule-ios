//
//  BSSchedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSTime {
    public var time: String;
}

public struct BSPeriod {
    public var startTime: BSTime;
    public var endTime: BSTime;
    public var name: String;
    public var key: String;
}

public struct BSScheduleTable {
    
    public var schedules: [String: BSSchedule];
    
    public func toString() -> String? {
        var scheduleTableObject = [String: [String: Any]]();
        
        schedules.forEach { (key, schedule) in
            var scheduleObject = [String: Any]();
            scheduleObject["name"] = schedule.name;
            schedule.periods.forEach { period in
                var periodObject = [String:Any]();
                periodObject["name"] = period.name;
                periodObject["startTime"] = period.startTime.time;
                periodObject["endTime"] = period.endTime.time;
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
    public var name: String;
    public var periods: [BSPeriod];
    public func getPeriodFor(time: BSTime) -> BSPeriod? {
        return nil;
    }
    
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
                            startTime: BSTime(time: startString),
                            endTime: BSTime(time: endString),
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
