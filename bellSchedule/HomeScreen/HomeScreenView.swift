//
//  ContentView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import BellScheduleKit

struct HomeScreenView: View {
    
    @ObservedObject public var contextWrapper: BSContextWrapper;
    
    var body: some View {
        
        ZStack {
            Color("AppColor")
                .ignoresSafeArea()
            VStack {
                AccessoriesView(contextWrapper: contextWrapper).accessibilityElement(children: .contain).accessibilitySortPriority(9);
                Spacer()
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
                            HomeScreenSmallText(text: Binding.constant(""));
                            HomeScreenLargeText(text: Binding.constant("Unknown error")).accessibilityLabel("The bell schedule app failed to load. Please try again.").accessibilitySortPriority(10);
                            HomeScreenSmallText(text: Binding.constant(""));
                        }
                    case .failed:
                        HomeScreenSmallText(text: Binding.constant(""));
                        HomeScreenLargeText(text: Binding.constant("Failed to load")).accessibilityLabel("The bell schedule app failed to load. Please try again.").accessibilitySortPriority(10);
                        HomeScreenSmallText(text: Binding.constant(""));
                    case .loading:
                        HomeScreenSmallText(text: Binding.constant(""));
                        HomeScreenLargeText(text: Binding.constant("Loading")).accessibilityLabel("The bell schedule app is loading.");
                        HomeScreenSmallText(text: Binding.constant(""));
                    }
                        
                }.accessibilityElement(children: .contain).accessibilitySortPriority(10)
                Spacer()
            }.accessibilityElement(children: .contain)
        }.accessibilityElement(children: .contain)
    }
}


