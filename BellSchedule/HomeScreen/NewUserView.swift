//
//  NewUserView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import Foundation
import SwiftUI

/// View to show to users who are new to this app or update
struct NewUserView: View {
    
    /// Parent view
    var app: BellScheduleAppView
    
    /// Body of the popover
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to the DHS Bell Schedule App, Version 3.2.0")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.leading)
            Text("9 years later, it's still getting updates")
                .padding([.top,.bottom], 1.0)
                .padding(.bottom, 10.0)
            Text("What's New?")
                .font(.headline)
            Text("""
- I have made some backend changes to reduce the file size of the app binary and to improve the speed & reliability of the app experience.

Thank you for using the Bell Schedule App!

- Ari Stassinopoulos
Dublin High School Class of 2020
""".trimmingCharacters(in: .whitespacesAndNewlines))
            Spacer()
            Button(action: continueToApp) {
                Text("Continue")
                    .frame(maxWidth:.infinity)
                    .accessibilityHint("Continue to app");

            }
            .buttonStyle(.borderedProminent)
            .tint(Color("AccentColor"))
        }
        .accessibilityElement(children: .contain)
        .padding()
    }
    
    func continueToApp() -> Void {
        withAnimation {
            app.firstTimeUser = false
        }
        
    }
}

