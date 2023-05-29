//
//  AccessoriesView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import SwiftUI
import BellScheduleKit

struct AccessoriesView: View {
    @ObservedObject public var contextWrapper: BSContextWrapper;
    @State var settingsShown =  false
    @State var infoShown = false
    
    var body: some View {
        HStack {
            Button (action: showSettings) {
                Image("baseline_settings_black_24pt")
                    .accessibilityHidden(false)
                    .accessibilityLabel("Settings")
                    .accessibilityHint("View Settings")
            }
            .disabled(contextWrapper.done)
            .accessibilitySortPriority(8)
            .accessibilityElement(children: .combine)
            .sheet(isPresented: $settingsShown) {
                NavigationStack {
                    if let context = contextWrapper.context {
                        SettingsView(context: context)
                            .navigationTitle("Settings")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
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
            Button(action: getInfo) {
                Image("baseline_info_black_24pt")
                    .accessibilityHidden(false)
                    .accessibilityHint("View Today's Schedule")
                    .accessibilityLabel("Today's Schedule")
            }
            .accessibilityElement(children: .combine)
            .accessibilitySortPriority(10)
            .disabled(contextWrapper.done)
            .sheet(isPresented: $infoShown) {
                NavigationStack {
                    if let context = contextWrapper.context {
                        TodayScheduleView(context: context)
                            .navigationTitle("Today's schedule")
                            .toolbar {
                                ToolbarItem(placement: .navigationBarLeading) {
                                    Button("Done") {
                                        infoShown = false;
                                    }
                                    .accessibilityLabel("Close today's schedule")
                                    .accessibilityHint("Close")
                                    .fontWeight(.bold)
                                }
                                ToolbarItem(placement:.navigationBarTrailing) {
                                    NavigationLink("All Schedules") {
                                        AllScheduleView(context: context)
                                            .navigationTitle("All schedules")
                                            .accessibilityElement(children: .contain);
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
    
    func getInfo() -> Void {
        infoShown = true;
    }
    
    func showSettings() -> Void {
        settingsShown = true;
    }
}
