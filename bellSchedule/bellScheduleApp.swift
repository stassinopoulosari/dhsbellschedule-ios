//
//  bellScheduleApp.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import FirebaseCore

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

struct Symbol: Hashable {
    public var defaultValue: String;
    public var symbol: String;
    private var storedValue: String?;
    var value: String {
        set {
            storedValue = (newValue.trimmingCharacters(in: .whitespacesAndNewlines)) == "" ? nil : newValue
        }
        get {
            storedValue ?? ""
        }
    }
    public init(defaultValue: String, symbol: String, storedValue: String? = nil) {
        self.defaultValue = defaultValue
        self.symbol = symbol
        self.storedValue = storedValue
    }
}

struct BellScheduleAppView: View {
    
    @State var firstTimeUser: Bool
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some View {
        
        HomeScreenView()
            .sheet(isPresented: $firstTimeUser) {
                NewUserView(app: self)
                    .interactiveDismissDisabled()
            }
            .preferredColorScheme(.dark)
            .background(Rectangle().foregroundColor(Color("AppColors")))
        
    }
    
}
