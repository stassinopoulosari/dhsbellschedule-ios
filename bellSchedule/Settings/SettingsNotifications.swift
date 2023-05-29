//
//  SettingsNotifications.swift
//  BellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-29.
//

import Foundation
import SwiftUI
import BellScheduleKit

struct NotificationsView: View {
    @ObservedObject public var context: BSContext;
    @ObservedObject public var notificationsModel = NotificationsModel();
    
    @State private var notificationsSettingsModel = BSPersistence.loadUserNotificationsSettings();
    @State private var notificationsEnabled = false;
    @State private var timeSelection: Double = 5;
    
    @Environment(\.scenePhase) var scenePhase;
    
    var body: some View {
        VStack {
            if notificationsModel.granted {
                List {
                    Toggle("Enable notifications", isOn: $notificationsSettingsModel.notificationsOn)
                        .toggleStyle(.switch)
                        .onChange(of: notificationsSettingsModel.notificationsOn) { newValue in
                            notificationsModel.request();
                            BSPersistence.save(userNotificationsSettings: notificationsSettingsModel)
                            if(notificationsSettingsModel.notificationsOn) {
                                Notifications(context: context, settings: notificationsSettingsModel).scheduleNotifications();
                            } else {
                                UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                            }
                        }
                        .accessibilityHint("Enable notifications for period ends")
                        .accessibilityValue(notificationsSettingsModel.notificationsOn ? "Notifications On" : "Notifications Off");
                    Picker("Notification warning", selection: $notificationsSettingsModel.notificationsInterval) {
                        ForEach([0.5, 1, 2, 5, 10, 15], id: \.self) { timeInterval in
                            if(timeInterval < 1) {
                                Text(String(Int(timeInterval * 60)) + " seconds")
                            } else {
                                Text(String(Int(timeInterval)) + " minute\(Int(timeInterval) == 1 ? "" : "s")");
                            }
                        }
                    }
                    .accessibilityHint("Change how long before a period ends the notification is received")
                    .disabled(!notificationsSettingsModel.notificationsOn)
                    .onChange(of: notificationsSettingsModel.notificationsInterval) { newValue in
                        notificationsModel.request();
                        BSPersistence.save(userNotificationsSettings: notificationsSettingsModel)
                        if(notificationsSettingsModel.notificationsOn) {
                            Notifications(context: context, settings: notificationsSettingsModel).scheduleNotifications();
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .listStyle(.plain)
            }  else {
                if !notificationsModel.loaded {
                    Text("Waiting for user to grant notifications permissions.")
                }
            }
            if notificationsModel.granted {
                Button("Test push notifications", action: {
                    print("Test push notifications");
                    notificationsModel.request();
                    Notifications(context: context, settings: notificationsSettingsModel).testNotifications();
                })
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
            } else if notificationsModel.loaded {
                Text("Notifications permission not granted. Please click the button below to grant notifications permission.")
                    .onChange(of: scenePhase) { newValue in
                        print(newValue)
                        if newValue == .active {
                            notificationsModel.request();
                        }
                    };
                Button("Grant permission", action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                })
                .buttonStyle(.borderedProminent)
                .tint(Color("AccentColor"))
                Button("Try again", action: {
                    notificationsModel.request();
                })
                .buttonStyle(.borderedProminent)
                .tint(Color("AppColor"))
            }
            Spacer().accessibilityHidden(true);
        }.onAppear {
            notificationsModel.request();
        }
    }
}
