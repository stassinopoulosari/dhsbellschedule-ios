//
//  BSSchedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-25.
//

import Foundation

public struct BSTime: Comparable {
    public static func < (lhs: BSTime, rhs: BSTime) -> Bool {
        if let ldate = lhs.date, let rdate = rhs.date {
            return ldate < rdate;
        }
        return false;
    }
    
    public static func > (lhs: BSTime, rhs: BSTime) -> Bool {
        if let ldate = lhs.date, let rdate = rhs.date {
            return ldate > rdate;
        }
        return true;
        
    }
    
    public static func == (lhs: BSTime, rhs: BSTime) -> Bool {
        if let ldate = lhs.date, let rdate = rhs.date {
            return ldate == rdate;
        }
        return false;
    }
    
    public var date: Date? {
        get {
            if let date = Calendar.current.date(bySettingHour: hours, minute: minutes, second: 0, of: Date.now) {
                return date;
            }
            return nil;
        }
        set {
            let dateFormatter = DateFormatter();
            dateFormatter.dateFormat = "HH:mm";
            if let date = newValue {
                self.string = dateFormatter.string(from: date);
            }
        }
    }
    
    public static var usesAMPM: Bool {
        let locale = NSLocale.current
        let dateFormat = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale)!
        if dateFormat.firstRange(of: "a") != nil {
            return true
        }
        else {
            return false
        }
    }
    
    public var localString: String {
        get {
            let dateFormatter = DateFormatter()
            if(BSTime.usesAMPM) {
                dateFormatter.dateFormat = "h:mm a"
            } else {
                dateFormatter.dateFormat = "HH:mm";
            }
            if let date = self.date {
                return dateFormatter.string(from: date)
            } else {
                return "Invalid Date";
            }
        }
    }
    
    private static func hours(fromString time: String) -> Int {
        let hoursString = String(time.split(separator: ":", maxSplits: 1)[0])
        //        print(hoursString)
        if let hoursInt = Int(hoursString) {
            return hoursInt;
        }
        return 0;
    }
    private static func minutes(fromString time: String) -> Int {
        let minutesString = String(time.split(separator: ":", maxSplits: 1)[1])
        //        print("time: \(time); minutesString: \(minutesString)")
        //        print(minutesString)
        if let minutesInt = Int(minutesString) {
            return minutesInt;
        }
        return 0;
    }
    private var hours: Int {
        return BSTime.hours(fromString: string);
    }
    private var minutes: Int {
        return BSTime.minutes(fromString: string);
    }
    
    public init(date: Date) {
        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "HH:mm";
        self.string = dateFormatter.string(from: date);
    }
    
    public init(string: String) {
        //        print(string);
        //        print(BSTime.hours(fromString: string))
        //        print(BSTime.minutes(fromString: string))
        //        print(Calendar.current.date(
        //            bySettingHour: BSTime.hours(fromString: string),
        //            minute: BSTime.minutes(fromString: string),
        //            second: 0, of: Date.now
        //        ))
        if Calendar.current.date(
            bySettingHour: BSTime.hours(fromString: string),
            minute: BSTime.minutes(fromString: string),
            second: 0, of: Date.now
        ) != nil {
            self.string = string;
        } else {
            self.string = "00:00";
        }
    }
    
    public var string: String;
}

public struct BSPeriod {
    public var startTime: BSTime;
    public var endTime: BSTime;
    public var name: String;
    public var key: String;
    public var isCurrent: Bool {
        let date = Date.now;
        let dateTime = BSTime(date: date);
        return dateTime >= startTime && dateTime < endTime;
    };
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
    public var displayName: String {
        return name.replacingOccurrences(of: "![0-9]*( )?", with: "", options: .regularExpression).replacingOccurrences(of: "ZZZ", with: "");
    };
    public var periods: [BSPeriod];
    
    public var currentPeriod: BSPeriod? {
        var currentPeriod: BSPeriod? = nil;
        periods.forEach { period in
            if(period.isCurrent) {
                currentPeriod = period;
            }
        }
        return currentPeriod;
    }
    
    public static func from(dictionary scheduleObject: [String: Any]) -> BSSchedule? {
        var periods = [BSPeriod]();
        if scheduleObject["hidden"] != nil {
            return nil;
        }
        //        print("Passed nil test")
        if let scheduleName = scheduleObject["name"] as? String {
            scheduleObject.keys.sorted().forEach { key in
                if(key == "name") {
                    return;
                }
                //                print(key)
                //                print(scheduleObject[key]);
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

