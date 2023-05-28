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

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
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
            .background(Rectangle().foregroundColor(Color("AppColors")))
        
    }
    
}
