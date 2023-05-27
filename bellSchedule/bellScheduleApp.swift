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
    var body: some Scene {
        WindowGroup {
            BellScheduleAppView(firstTimeUser: true)
        }
    }
}

struct BellScheduleAppView: View {
    
    @State var firstTimeUser: Bool
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var contextWrapper: BSContextWrapper = BSContextWrapper.from(databaseReference: Database.database().reference()) {
        
    };
    
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
