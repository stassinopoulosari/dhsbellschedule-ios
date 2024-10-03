//
//  NewUserView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import Foundation
import SwiftUI

struct NewUserView: View {
    var app: BellScheduleAppView
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Welcome to the DHS Bell Schedule App, Version 3.1.0")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.leading)
            Text("8 years later, it's still getting updates")
                .padding([.top,.bottom], 1.0)
                .padding(.bottom, 10.0)
            Text("What's New?")
                .font(.headline)
            Text("""
- There is now a calendar view for you to view all the schedules in the current month
- I have added a custom notification sound
- You may now silence the notifications for Zero Period if you so choose

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

//struct NewUserView_Preview: PreviewProvider {
//    static var previews: some View {
//        BellScheduleAppView(firstTimeUser: true)
//    }
//}
