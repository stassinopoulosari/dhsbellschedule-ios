//
//  BSPeriod.swift
//  BellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-29.
//

import Foundation

/// Time representation
public struct BSTime: Comparable {
    
    /// Compare two times
    /// - Parameter lhs: The left time to compare
    /// - Parameter rhs: The right time to compare
    /// - Returns: Whether the time on the left is less than the time on the right
    public static func < (lhs: BSTime, rhs: BSTime) -> Bool {
        if let ldate = lhs.date, let rdate = rhs.date {
            return ldate < rdate;
        }
        return false;
    }
    
    /// Compare two times
    /// - Parameter lhs: The left time to compare
    /// - Parameter rhs: The right time to compare
    /// - Returns: Whether the time on the left is greater than the time on the right
    public static func > (lhs: BSTime, rhs: BSTime) -> Bool {
        if let ldate = lhs.date, let rdate = rhs.date {
            return ldate > rdate;
        }
        return true;
        
    }
    
    /// Compare two times
    /// - Parameter lhs: The left time to compare
    /// - Parameter rhs: The right time to compare
    /// - Returns: Whether the time on the left is equal to the time on the right
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
        if let hoursInt = Int(hoursString) {
            return hoursInt;
        }
        return 0;
    }
    private static func minutes(fromString time: String) -> Int {
        let minutesString = String(time.split(separator: ":", maxSplits: 1)[1])
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

public struct BSPeriod: Hashable {
    public var identifier: String {
        return key;
    }
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    public static func == (lhs: BSPeriod, rhs: BSPeriod) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    public var startTime: BSTime;
    public var endTime: BSTime;
    public var name: String;
    public var key: String;
    public func isCurrent(forDate date: Date) -> Bool {
        let dateTime = BSTime(date: date);
        return dateTime >= startTime && dateTime < endTime;
    }
    public var isCurrent: Bool {
        return isCurrent(forDate: Date.now)
    };
}
