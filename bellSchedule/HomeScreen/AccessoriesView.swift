import SwiftUI
import BellScheduleKit

/// Accessories View
/// ==========
/// Display the top buttons and class name.
struct AccessoriesView: View {
    @ObservedObject public var contextWrapper: BSContextWrapper;
    
    ///# SettingsShown
    ///True if the settings screen is currently up
    @State var settingsShown =  false
    /// # InfoShown
    /// True if the schedules or all schedules screen is up
    @State var infoShown = false
    
    /// # Body
    /// Show the aforementioned views
    var body: some View {
        HStack {
            // Show settings button (2nd in a11y order)
            Button (action: showSettings) {
                Image("baseline_settings_black_24pt")
                    .accessibilityHidden(false)
                    .accessibilityLabel("Settings")
                    .accessibilityHint("View Settings")
            }
            // Disable the buttons if the context is not valid
            .disabled(contextWrapper.hasNoValidContext)
            .accessibilitySortPriority(8)
            .accessibilityElement(children: .combine)
            // Present settings when pressing the button
            .sheet(isPresented: $settingsShown) {
                NavigationStack {
                    if let context = contextWrapper.context {
                        SettingsView(context: context)
                            .navigationTitle("Settings")
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Done") {
                                        settingsShown.toggle();
                                    }
                                    .fontWeight(.bold)
                                }
                            }
                    }
                }
            }
            .tint(.white)
            Spacer()
            // Class title (last in a11y order)
            switch(contextWrapper.state) {
            case .loading:
                Text("")
            case .loadedWithErrors(_), .loadedWithoutErrors:
                if let context = contextWrapper.context {
                    @ObservedObject var contextObserver = BSContextObserver(withContext: context);
                    ClassNameTextView(contextObserver: contextObserver)
                        .accessibilityElement(children: .contain);
                } else {
                    Text("");
                }
            case .failed(_):
                Text("")
            }
            Spacer()
            // Information button (first in a11y order)
            Button(action: getInfo) {
                Image("baseline_info_black_24pt")
                    .accessibilityHidden(false)
                    .accessibilityHint("View Today's Schedule")
                    .accessibilityLabel("Today's Schedule")
            }
            .accessibilityElement(children: .combine)
            .accessibilitySortPriority(10)
            .disabled(contextWrapper.hasNoValidContext)
            .sheet(isPresented: $infoShown) {
                NavigationStack {
                    if let context = contextWrapper.context {
                        TodayScheduleView(context: context)
                            .navigationTitle("Today's schedule")
                            .toolbar {
                                ToolbarItem(placement: .topBarLeading) {
                                    Button("Done") {
                                        infoShown = false;
                                    }
                                    .accessibilityLabel("Close today's schedule")
                                    .accessibilityHint("Close")
                                    .fontWeight(.bold)
                                }
                                ToolbarItemGroup(placement:.topBarTrailing) {
                                    NavigationLink {
                                        CalendarView(context: context)
                                            .navigationTitle("Calendar")
                                            .accessibilityElement(children: .contain)
                                    } label: {
                                        Image("calendar_month_black")
                                    }
                                    .accessibilityLabel("Calendar")
                                    .accessibilityHint("View the calendar")
                                    NavigationLink {
                                        AllScheduleView(context: context).navigationTitle("All schedules")
                                            .accessibilityElement(children: .contain)
                                    } label: {
                                        Image("view_list_black")
                                    }
                                    .accessibilityLabel("All schedules")
                                    .accessibilityHint("View all schedules")
                                }
                                
                                
                            }.accessibilityElement(children: .contain)
                    }
                }
                .accessibilityElement(children: .contain)
            }
            .tint(.white)
        }
        .padding()
        .accessibilityElement(children: .contain)
    }
    
    private func getInfo() -> Void {
        infoShown = true;
    }
    
    
    private func showSettings() -> Void {
        settingsShown = true;
    }
}
