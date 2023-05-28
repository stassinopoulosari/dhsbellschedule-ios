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
            Text("Welcome to the DHS Bell Schedule App, Version 3.0.0")
                .font(.largeTitle.weight(.heavy))
                .multilineTextAlignment(.leading)
            Text("7 years later, it's still getting updates")
                .padding([.top,.bottom], 1.0)
                .padding(.bottom, 10.0)
            Text("What's New?")
                .font(.headline)
            Text("""
- The app has been rewritten from scratch using SwiftUI.
- I have reduced data usage to improve your experience (and my pocketbook).
- Bug fixes and performance improvements (of course).

Thank you for using the Bell Schedule App!

- Ari Stassinopoulos, Class of 2020
""".trimmingCharacters(in: .whitespacesAndNewlines))
            Spacer()
            Button(action: continueToApp) {
                Text("Continue")
                    .frame(maxWidth:.infinity)

            }
            .buttonStyle(.borderedProminent)
            .tint(Color("AppColors"))
        }
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
