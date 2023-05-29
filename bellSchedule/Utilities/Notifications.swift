//
//  Notifications.swift
//  BellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-28.
//

import Foundation
import UserNotifications
import BellScheduleKit

class NotificationsModel: ObservableObject {
    private var center = UNUserNotificationCenter.current();
    @Published public var loaded = false;
    @Published public var granted = false;
    
    public func request() {
        self.loaded = false;
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.granted = granted;
                self.loaded = true;
            }
        }
    }
}

struct Notifications {
    private var center: UNUserNotificationCenter;
    private var settings: BSPersistence.NotificationsSettings;
    public var context: BSContext;
    
    public init(context: BSContext, settings: BSPersistence.NotificationsSettings) {
        self.center = UNUserNotificationCenter.current();
        self.context = context;
        self.settings = settings;
    }
    
    public func testNotifications() {
        scheduleNotifications();
        center.requestAuthorization(options:[.alert,.sound]) { granted, error in
            if error != nil {
                return;
            }
            if !granted {
                return;
            }
            let content = UNMutableNotificationContent();
            content.title = "Test notification"
            content.body = "This is a test notification"
            content.interruptionLevel = .timeSensitive;
            content.sound = .default;
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false);
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
        }
    }
    
    public func scheduleNotifications() {
        
        if !settings.notificationsOn {
            return;
        }
        
        let maximumNotifications = 63;
        
        center.requestAuthorization(options:[.alert,.sound]) { granted, error in
            if error != nil {
                return;
            }
            if !granted {
                return;
            }
            center.removeAllPendingNotificationRequests();
            center.removeAllDeliveredNotifications();
            var numberScheduled = 0;
            var date = Date.now
            let calendar = context.calendar;
            var schedule = calendar.currentSchedule;
            var dateAdjustmentInterval = 0.0;
            var periodIndex = 0;
            var daysWithoutSchedule = 0
            while(numberScheduled <= maximumNotifications) {
                if let currentSchedule = schedule {
                    daysWithoutSchedule = 0;
                    if(periodIndex >= currentSchedule.periods.count) {
                        date = date.addingTimeInterval(24 * 60 * 60);
                        dateAdjustmentInterval += 24 * 60 * 60 * 1.0;
//                        print(date);
                        schedule = calendar.currentSchedule(forDate: date);
                        periodIndex = 0;
                        continue;
                    }
                    let period = currentSchedule.periods[periodIndex];
                    periodIndex += 1;
//                    print(periodIndex);
                    if(context.symbolTable.render(templateString: period.name) == "Passing Period") {
                        continue;
                    }
                    if let endDate = period.endTime.date, let startDate = period.startTime.date {
                        let interval = settings.notificationsInterval * 60 * -1;
                        let notificationDate = endDate.addingTimeInterval(interval + dateAdjustmentInterval);
                        if(startDate.addingTimeInterval(dateAdjustmentInterval) > notificationDate || notificationDate < Date.now) {
                            continue;
                        }
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
//                        print(dateComponents)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        let content = UNMutableNotificationContent()
                        content.title = "\(context.symbolTable.render(templateString: period.name)) is ending soon!";
                        if abs(interval) < 1 {
                            content.body = "\(Int(abs(interval))) seconds remain."
                        } else {
                            content.body = "\(Int(abs(interval) / 60)) minutes remain."
                        }
                        content.sound = .default
                        content.interruptionLevel = .timeSensitive;
                        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
//                        print("Scheduled: \(notificationDate); Title: \(content.title); Body: \(content.body)");
                        numberScheduled += 1;
                    }
                } else {
                    daysWithoutSchedule += 1;
                    if(daysWithoutSchedule >= 7) {
                        break;
                    }
                    date = date.addingTimeInterval(24 * 60 * 60);
                    dateAdjustmentInterval += 24 * 60 * 60 * 1.0;
//                    print(date);
                    schedule = calendar.currentSchedule(forDate: date);
                    periodIndex = 0;
                    continue;
                }
            }
            center.getPendingNotificationRequests { requests in
                print(requests.count);
            }
        }
    }
}
