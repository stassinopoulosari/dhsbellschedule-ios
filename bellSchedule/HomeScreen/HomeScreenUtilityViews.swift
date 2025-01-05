import SwiftUI
import BellScheduleKit
import WidgetKit

/// Display small text for the home screen.
struct HomeScreenSmallTextView: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 17))
            .foregroundColor(.white)
    }
}

/// Display large text for the home screen.
struct HomeScreenLargeTextView: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 50, weight:.heavy))
            .padding([.leading,.trailing], 10)
            .foregroundColor(.white)
    }
}

/// Display a real-time start time from a ContextObserver
struct StartTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallTextView(text: $contextObserver.startTimeString)
            .accessibilityLabel("Class start time")
            .accessibilityValue(contextObserver.startTimeString)
    }
}

/// Display a real-time end time from a ContextObserver
struct EndTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenLargeTextView(text: $contextObserver.endTimeString)
            .accessibilityLabel("Class end time")
            .accessibilityValue(contextObserver.endTimeString)

    }
}

/// Display a real-time countdown from a ContextObserver
struct CountdownTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        let hours = contextObserver.countdownTime / 60 / 60;
        let minutes = contextObserver.countdownTime / 60 % 60;
        let seconds = contextObserver.countdownTime % 60;

        HomeScreenSmallTextView(text: $contextObserver.countdownTimeString)
            .onAppear {
                WidgetCenter.shared.reloadAllTimelines()
            }
            .accessibilityLabel("Class countdown")
            .accessibilityValue("\(hours > 0 ? String(hours) + " hours, " : "")\(minutes) minutes, \(seconds) seconds")

    }
}

/// Class name
/// - Display a real-time class name from a ContextObserver
struct ClassNameTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallTextView(text: $contextObserver.classNameString)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current class: \(contextObserver.classNameString)")
    }
}
