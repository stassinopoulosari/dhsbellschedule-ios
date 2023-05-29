//
//  HomeScreenUtilities.swift
//  BellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-29.
//

import Foundation
import SwiftUI
import BellScheduleKit
import WidgetKit

struct HomeScreenSmallText: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 17))
            .foregroundColor(.white)
    }
}

struct HomeScreenLargeText: View {
    @Binding var text: String;
    
    var body: some View {
        Text(text)
            .font(.system(size: 50, weight:.heavy))
            .padding([.leading,.trailing], 10)
            .foregroundColor(.white)
    }
}

struct StartTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallText(text: $contextObserver.startTimeString)
            .accessibilityLabel("Class start time")
            .accessibilityValue(contextObserver.startTimeString)
    }
}

struct EndTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenLargeText(text: $contextObserver.endTimeString)
            .accessibilityLabel("Class end time")
            .accessibilityValue(contextObserver.endTimeString)

    }
}


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

struct ClassNameTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallText(text: $contextObserver.classNameString)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Current class: \(contextObserver.classNameString)")
    }
}
