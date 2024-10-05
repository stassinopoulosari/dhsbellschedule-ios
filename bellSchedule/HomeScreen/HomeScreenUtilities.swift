import SwiftUI
import BellScheduleKit
import WidgetKit

/// Home Screen Small Text
/// - Display small text for the home screen.
struct HomeScreenSmallText: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 17))
            .foregroundColor(.white)
    }
}

/// Home Screen Large Text
/// - Display large text for the home screen.
struct HomeScreenLargeText: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 50, weight:.heavy))
            .padding([.leading,.trailing], 10)
            .foregroundColor(.white)
    }
}

/// Start TIme Text View
/// - Display a real-time start time from a ContextObserver
struct StartTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallText(text: $contextObserver.startTimeString)
            .accessibilityLabel("Class start time")
            .accessibilityValue(contextObserver.startTimeString)
    }
}

/// End TIme Text View
/// - Display a real-time end time from a ContextObserver
struct EndTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenLargeText(text: $contextObserver.endTimeString)
            .accessibilityLabel("Class end time")
            .accessibilityValue(contextObserver.endTimeString)

    }
}

/// Countdown Text View
/// - Display a real-time countdown from a ContextObserver
struct CountdownTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        let hours = contextObserver.countdownTime / 60 / 60;
        let minutes = contextObserver.countdownTime / 60 % 60;
        let seconds = contextObserver.countdownTime % 60;


        HomeScreenSmallText(text: $contextObserver.countdownTimeString)
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
        HomeScreenSmallText(text: $contextObserver.classNameString)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current class: \(contextObserver.classNameString)")
    }
}
