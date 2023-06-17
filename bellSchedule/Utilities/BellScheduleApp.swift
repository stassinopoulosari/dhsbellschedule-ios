import SwiftUI
import FirebaseCore
import FirebaseDatabase
import BellScheduleKit


/// App Delegate class as required for Firebase and UNUserNotifications
/// ==========
/// This class
/// - Configures Firebase
/// - Sets the UNUserNotificationCenter to show banners in the app
class AppDelegate: NSObject, UIApplicationDelegate,
UNUserNotificationCenterDelegate{
    /// application(_,didFinishLaunchingWithOptions:)
    ///  Thiis function confitgures the Firebase client and sets this `AppDelegate` instance to the delegate for user notifications
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        return true
    }
    /// userNotificationCenter(_,willPresent,withCompletionHandler)
    /// This function configures how the application shows notifications (it shows them as a banner
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.banner,.sound]);
    }
}


/// BellScheduleApp
/// ==========
/// Main entry point for the app in SwiftUI
@main
struct BellScheduleApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    /// Body
    /// ==========
    /// Configure the context wrapper for the home screen and configure whether this is a first-time user.
    var body: some Scene {
        let contextWrapper: BSContextWrapper = BSContextWrapper.from(databaseReference: Database.database().reference()) {
        };
        WindowGroup {
            BellScheduleAppView(firstTimeUser: BSPersistence.firstTimeUser(), contextWrapper: contextWrapper)
        }
    }
}

/// BellScheduleAppView
/// =========
/// Main subview of the app. All ofther views are child views of this app.
struct BellScheduleAppView: View {
    
    /// First Time User
    ///  ==========
    ///  `true` if the user has not used version 3.0 yet, false otherwise
    @State var firstTimeUser: Bool
    /// ContextWrapper
    /// ===========
    /// Pased to subviews
    @ObservedObject var contextWrapper: BSContextWrapper;
    
    /// Body
    /// ===========
    /// Display the New User View if the app has a new user, otherwise show the home screen.
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
