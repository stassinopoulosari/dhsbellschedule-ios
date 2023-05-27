//
//  AccessoriesView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import SwiftUI
import BellScheduleKit

struct AccessoriesView: View {
    @State public var contextWrapper: BSContextWrapper;
    @State var settingsShown =  false
    @State var infoShown = false
    
    var body: some View {
        HStack {
            
            Button (action: showSettings) {
                Image("baseline_settings_black_24pt")
            }
            .disabled(contextWrapper.done)
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
            Text("class0")
                .foregroundColor(.white)
            Spacer()
            Button(action: getInfo) {
                Image("baseline_info_black_24pt")
            }
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
                                    .fontWeight(.bold)
                                }
                                ToolbarItem(placement:.navigationBarTrailing) {
                                    NavigationLink("All Schedules") {
                                        AllScheduleView(context: context)
                                            .navigationTitle("All schedules")
                                    }
                                }
                            }
                    }
                }
            }
            .tint(.white)
        }
        .padding()
    }
    func getInfo() -> Void {
        infoShown = true;
    }
    
    func showSettings() -> Void {
        settingsShown = true;
    }
}
