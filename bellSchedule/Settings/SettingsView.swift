//
//  SettingsView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import BellScheduleKit

enum Setting {
    case editClassNames
    case about
    case sendFeedback
    case notifications
}

struct SettingsView: View {
    
    public var context: BSContext;
    
    private let settings: [Setting] = [
        .editClassNames,
        .notifications,
        .about,
        .sendFeedback
    ]
    
    var body: some View {
        List(settings, id: \.self) {
            settingsLink in
            
            switch settingsLink {
            case .editClassNames:
                NavigationLink{
                    EditClassNamesView(context: context)
                        .navigationTitle("Edit class names")
                } label: {
                    Text("Edit class names")
                }
            case .about:
                NavigationLink {
                    AboutView()
                        .navigationTitle("About")
                } label: {
                    Text("About")
                }
            case .sendFeedback:
                Button("Send Feedback") {
                    if let formUrl = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSePaLX8E9wJ2GrronsBW4UwzooceSVtUqsdzDkILXOy596Qgg/viewform") {
                        UIApplication.shared.open(formUrl, options:[:], completionHandler: nil);
                    }
                }
            case .notifications:
                NavigationLink {
                    NotificationsView(context: context)
                        .navigationTitle("Notifications")
                } label: {
                    Text("Notifications")
                }
            }
        }.listStyle(.plain)
        
    }
}


