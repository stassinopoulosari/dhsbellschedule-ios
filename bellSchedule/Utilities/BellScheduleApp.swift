//
//  bellScheduleApp.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import FirebaseCore
import FirebaseDatabase
import BellScheduleKit

class AppDelegate: NSObject, UIApplicationDelegate,
UNUserNotificationCenterDelegate{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        return true
    }
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        // Update the app interface directly.
        
        // Show a banner
        completionHandler(.banner)

    }
}

@main
struct bellScheduleApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        let contextWrapper: BSContextWrapper = BSContextWrapper.from(databaseReference: Database.database().reference()) {
        };
        WindowGroup {
            BellScheduleAppView(firstTimeUser: BSPersistence.firstTimeUser(), contextWrapper: contextWrapper)
        }
    }
}

struct BellScheduleAppView: View {
    
    @State var firstTimeUser: Bool
    @ObservedObject var contextWrapper: BSContextWrapper;
    
    var body: some View {
        HomeScreenView(contextWrapper: contextWrapper)
            .sheet(isPresented: $firstTimeUser) {
                NewUserView(app: self)
                    .interactiveDismissDisabled()
            }
            .preferredColorScheme(.dark)
            .background(Rectangle().foregroundColor(Color("AppColor")))
        
    }
    
}
