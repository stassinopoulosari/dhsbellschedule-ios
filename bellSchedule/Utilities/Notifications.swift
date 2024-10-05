import Foundation
import UserNotifications
import BellScheduleKit

/// Notifications Model
/// =========
/// Model notifications for the settings view
class NotificationsModel: ObservableObject {
    private var center = UNUserNotificationCenter.current();
    
    /// Loaded
    /// ==========
    /// Tell the parent view if the authorization dialog has been answered
    @Published public var loaded = false;
    /// Granted
    /// =========
    /// Tell the parent view if the authorization has been granted
    @Published public var granted = false;
    
    /// Request
    /// =========
    /// Request authorization. The first time this is called, it will show a dialog.
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

/// Notifications
/// ==========
/// Handle notifications for the app
struct Notifications {
    private var center: UNUserNotificationCenter;
    private var settings: BSPersistence.NotificationsSettings;
    
    /// Context
    /// =========
    /// BSContext representing the app (for use in symbols and schedules)
    public var context: BSContext;
    
    /// Initializer
    /// =========
    /// Create a NotificationCenter and set instance variables
    public init(context: BSContext, settings: BSPersistence.NotificationsSettings) {
        self.center = UNUserNotificationCenter.current();
        self.context = context;
        self.settings = settings;
    }
    
    /// Test Notification
    /// ==========
    /// Display a test notification to the user
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
            content.sound = UNNotificationSound(named: UNNotificationSoundName("shimmerBell.caf"))
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false);
            center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))

            DispatchQueue.main.asyncAfter(deadline: .now() + 5.1) {
                scheduleNotifications()
            }
        }
    }
    
    /// Schedule Notifications
    /// ==========
    /// If the user has notifications enabled, schedule them. Otherwise, don't.
    public func scheduleNotifications() {
        
        let maximumNotifications = 62;
        
        center.requestAuthorization(options:[.alert,.sound]) { granted, error in
            if error != nil {
                return;
            }
            if !granted {
                return;
            }
            center.removeAllPendingNotificationRequests();
            center.removeAllDeliveredNotifications();
            // Cancel scheduling if notifications are off
            if !settings.notificationsOn {
                return;
            }
            var numberScheduled = 0;
            var date = Date.now
            let calendar = context.calendar;
            var schedule = calendar.currentSchedule;
            var dateAdjustmentInterval = 0.0;
            var periodIndex = 0;
            var daysWithoutSchedule = 0
            var lastNotificationDate: Date?;
            while(numberScheduled < maximumNotifications) {
                if let currentSchedule = schedule {
                    daysWithoutSchedule = 0;
                    if(periodIndex >= currentSchedule.periods.count) {
                        date = date.addingTimeInterval(24 * 60 * 60);
                        dateAdjustmentInterval += 24 * 60 * 60 * 1.0;
                        schedule = calendar.currentSchedule(forDate: date);
                        periodIndex = 0;
                        continue;
                    }
                    let period = currentSchedule.periods[periodIndex];
                    periodIndex += 1;
                    // Do not notify for passing period
                    if(context.symbolTable.render(templateString: period.name) == "Passing Period") {
                        continue;
                    }
                    // Do not notify for Zero Period or Zero Period final if that is disabled
                    if(period.name.range(of: context.zeroPeriodSymbol) != nil && settings.skipZeroPeriod) {
                        continue;
                    }
                    if let endDate = period.endTime.date, let startDate = period.startTime.date {
                        let interval = settings.notificationsInterval * 60 * -1;
                        let notificationDate = endDate.addingTimeInterval(interval + dateAdjustmentInterval);
                        // Do not notify for a period of a length less than the interval or for past notifications
                        if(startDate.addingTimeInterval(dateAdjustmentInterval) > notificationDate || notificationDate < Date.now) {
                            continue;
                        }
                        lastNotificationDate = notificationDate;
                        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                        let content = UNMutableNotificationContent()
                        content.title = "\(context.symbolTable.render(templateString: period.name)) is ending soon";
                        // Add shimmer bell sound
                        content.sound = UNNotificationSound(named: UNNotificationSoundName("shimmerBell.caf"))
                        if abs(interval) < 60 {
                            content.body = "\(Int(abs(interval))) seconds remain"
                        } else {
                            content.body = "\(String(Int(abs(interval) / 60)) + " minute\(Int(abs(interval) / 60) == 1 ? "" : "s")") remain\(Int(abs(interval) / 60) == 1 ? "s" : "")"
                        }
                        content.interruptionLevel = .timeSensitive;
                        center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
                        numberScheduled += 1;
                    }
                } else {
                    // Do not schedule notifications past 7 days of no schedules
                    daysWithoutSchedule += 1;
                    if(daysWithoutSchedule >= 7) {
                        break;
                    }
                    date = date.addingTimeInterval(24 * 60 * 60);
                    dateAdjustmentInterval += 24 * 60 * 60 * 1.0;
                    schedule = calendar.currentSchedule(forDate: date);
                    periodIndex = 0;
                    continue;
                }

            }
            
            if numberScheduled == maximumNotifications, var notificationDate = lastNotificationDate {
                // Notify the user they are out of notifications
                notificationDate = notificationDate.addingTimeInterval(5);
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notificationDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let content = UNMutableNotificationContent()
                content.title = "Notifications exhausted";
                content.sound = .default;
                content.body = "Please open the Bell Schedule app to schedule more notifications.";
                content.interruptionLevel = .active;
                center.add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger))
            }
            
            center.getPendingNotificationRequests { requests in
                print(requests.count)
            }
        }
    }
}
