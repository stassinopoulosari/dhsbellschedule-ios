//
//  ContentView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import BellScheduleKit

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
    }
}

struct EndTimeTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenLargeText(text: $contextObserver.endTimeString)
    }
}


struct CountdownTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallText(text: $contextObserver.countdownTimeString)
    }
}

struct ClassNameTextView: View {
    @ObservedObject var contextObserver: BSContextObserver;
    
    var body: some View {
        HomeScreenSmallText(text: $contextObserver.classNameString)
    }
}



struct HomeScreenView: View {
    
    @ObservedObject public var contextWrapper: BSContextWrapper;
    
    private var startTime:  String {
        switch contextWrapper.state {
        case .loading:
            return "";
        case .loadedWithErrors(_), .loadedWithoutErrors:
            if let context = contextWrapper.context,
               let currentSchedule = context.calendar.currentSchedule,
               let currentPeriod = currentSchedule.currentPeriod {
                return currentPeriod.startTime.localString;
            }
            return ""
        case .failed(_):
            return "";
        }
    };
    
    private var endTime:  String {
        switch contextWrapper.state {
        case .loading:
            return "Loading";
        case .loadedWithErrors(_), .loadedWithoutErrors:
            if let context = contextWrapper.context,
               let currentSchedule = context.calendar.currentSchedule,
               let currentPeriod = currentSchedule.currentPeriod {
                return currentPeriod.endTime.localString;
            }
            return "No class"
        case .failed(_):
            return "Failed";
        }
    };
    
    var body: some View {
        
        ZStack {
            Color("AppColors")
                .ignoresSafeArea()
            VStack {
                AccessoriesView(contextWrapper: contextWrapper);
                Spacer()
                VStack {
                    switch contextWrapper.state {
                    case .loadedWithoutErrors, .loadedWithErrors:
                        if let context = contextWrapper.context {
                            @ObservedObject var contextObserver = BSContextObserver(withContext: context);
                            StartTimeTextView(contextObserver: contextObserver);
                            EndTimeTextView(contextObserver: contextObserver);
                            CountdownTextView(contextObserver: contextObserver);
                        } else {
                            HomeScreenSmallText(text: Binding.constant(""));
                            HomeScreenLargeText(text: Binding.constant("Unknown error"));
                            HomeScreenSmallText(text: Binding.constant(""));
                        }
                    case .failed:
                        HomeScreenSmallText(text: Binding.constant(""));
                        HomeScreenLargeText(text: Binding.constant("Failed to load"));
                        HomeScreenSmallText(text: Binding.constant(""));
                    case .loading:
                        HomeScreenSmallText(text: Binding.constant(""));
                        HomeScreenLargeText(text: Binding.constant("Loading"));
                        HomeScreenSmallText(text: Binding.constant(""));
                    }
                        
                }
                Spacer()
            }
        }
    }
}


