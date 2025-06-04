import SwiftUI
import BellScheduleKit

struct HomeScreenView: View {
    
    /// Context wrapper
    /// ==========
    /// Display placeholder values until the context is loaded
    @ObservedObject public var contextWrapper: BSContextLoader;
    
    /// View body
    var body: some View {
        
        /// Show backgrounf
        ZStack {
            Color("AppColor")
                .ignoresSafeArea()
                .accessibilityHidden(true)
            /// Vertical stack of the rest of the home screen
            VStack {
                /// Settings, classname, info
                AccessoriesView(contextWrapper: contextWrapper).accessibilityElement(children: .contain).accessibilitySortPriority(9);
                Spacer()
                /// Middle view showing start, end time and countdown
                VStack {
                    switch contextWrapper.state {
                    case .loadedWithoutErrors, .loadedWithErrors:
                        if let context = contextWrapper.context {
                            @ObservedObject var contextObserver = BSContextObserver(withContext: context);
                            StartTimeTextView(contextObserver: contextObserver).accessibilitySortPriority(8);
                            EndTimeTextView(contextObserver: contextObserver).accessibilityLabel("Class end time").accessibilitySortPriority(10).onAppear() {
                                Notifications(context: context, settings: BSPersistence.loadUserNotificationsSettings()).scheduleNotifications();
                            };
                            CountdownTextView(contextObserver: contextObserver).accessibilityLabel("Countdown to next class").accessibilitySortPriority(9);
                        } else {
                            HomeScreenSmallTextView(text: Binding.constant(""));
                            HomeScreenLargeTextView(text: Binding.constant("Unknown error")).accessibilityLabel("The bell schedule app failed to load. Please try again.").accessibilitySortPriority(10);
                            HomeScreenSmallTextView(text: Binding.constant(""));
                        }
                    case .failed:
                        HomeScreenSmallTextView(text: Binding.constant(""));
                        HomeScreenLargeTextView(text: Binding.constant("Failed to load")).accessibilityLabel("The bell schedule app failed to load. Please try again.").accessibilitySortPriority(10);
                        HomeScreenSmallTextView(text: Binding.constant(""));
                    case .loading:
                        HomeScreenSmallTextView(text: Binding.constant(""));
                        HomeScreenLargeTextView(text: Binding.constant("Loading")).accessibilityLabel("The bell schedule app is loading.");
                        HomeScreenSmallTextView(text: Binding.constant(""));
                    }
                        
                }.accessibilityElement(children: .contain).accessibilitySortPriority(10)
                Spacer()
            }.accessibilityElement(children: .contain)
        }.accessibilityElement(children: .contain)
    }
}


