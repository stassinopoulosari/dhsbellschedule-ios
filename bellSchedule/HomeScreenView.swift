//
//  ContentView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-13.
//

import SwiftUI
import BellScheduleKit

struct HomeScreenView: View {
    
    public var contextWrapper: BSContextWrapper;
    
    //    var app: BellScheduleAppView
    @State var startTime = ""
    @State var endTime = "No class"
    @State var countdown = ""
    
    var body: some View {
        ZStack {
            Color("AppColors")
                .ignoresSafeArea()
            VStack {
                AccessoriesView(contextWrapper: contextWrapper);
                Spacer()
                VStack {
                    Text(startTime)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    Text(endTime)
                        .font(.system(size: 50, weight:.heavy))
                        .padding([.leading,.trailing], 10)
                        .foregroundColor(.white)
                    Text(countdown)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
}

struct HomeScreenView_Preview: PreviewProvider {
    static var previews: some View {
        BellScheduleAppView(firstTimeUser: false)
    }
}


