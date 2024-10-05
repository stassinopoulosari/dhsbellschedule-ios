//
//  SettingsAbout.swift
//  BellSchedule
//
//  Created by Ari Stassinopoulos on 2024-10-05.
//

import SwiftUI

struct AboutView: View {
    var aboutText = [
        "**DHS Bell Schedule App version 3.1.0**",
        "*Written by Ari Stassinopoulos (c/o 2020) as a gift to the Dublin High School student body.*",
        "**[Tap here to view my website.](https://ari-s.com)**",
        "**[Tap here to view the source code.](https://github.com/stassinopoulosari/dhsbellschedule-ios)**",
        "The Bell Schedule App is funded thanks to generous contributions by the Parent-Student-Faculty-Organization (PFSO).",
        "Libraries:",
        "• Firebase",
        "\t• **[https://firebase.google.com](https://firebase.google.com)**",
        "• BellScheduleKit (Included in the source code for this project)",
        "Hello from beautiful Portland, Oregon!"
    ]
    var body: some View {
        List {
            VStack {
                ForEach(aboutText, id: \.self) { text in
                    // The .init makes the markdown work, it's weird af
                    Text(.init(text))
                        .frame(maxWidth: .infinity, alignment: .leading )
                        .padding([.bottom])

                }
            }
        }
    }
}
