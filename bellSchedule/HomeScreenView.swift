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
    
    private var startTime:  Binding<String>{
        Binding(
            get: {() -> String in
                switch contextWrapper.state {
                case .loading:
                    return "";
                case .loadedWithErrors(_), .loadedWithoutErrors:
                    if let context = contextWrapper.context, let currentSchedule = context.calendar.currentSchedule, let currentPeriod = currentSchedule.currentPeriod {
                        return currentPeriod.startTime.string;
                    }
                    return ""
                case .failed(_):
                    return "";
                }
            }, set: {_,_ in}
        )
    };
    
    private var endTime:  Binding<String>{
        Binding(
            get: {() -> String in
                switch contextWrapper.state {
                case .loading:
                    return "Loading";
                case .loadedWithErrors(_), .loadedWithoutErrors:
                    if let context = contextWrapper.context, let currentSchedule = context.calendar.currentSchedule, let currentPeriod = currentSchedule.currentPeriod {
                        return currentPeriod.endTime.string;
                    }
                    return "No class"
                case .failed(_):
                    return "Failed";
                }
            }, set: {_,_ in}
        )
    };
    
    private var countdown: Binding<String> {
        Binding(
            get: {() -> String in
                switch contextWrapper.state {
                case .loading:
                    return "";
                case .loadedWithErrors(_), .loadedWithoutErrors:
                    return ""
                case .failed(_):
                    return "";
                }
            }, set: {_,_ in}
        )
    }
    
    var body: some View {
        
        ZStack {
            Color("AppColors")
                .ignoresSafeArea()
            VStack {
                AccessoriesView(contextWrapper: contextWrapper);
                Spacer()
                VStack {
                    Text(startTime.wrappedValue)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                    Text(endTime.wrappedValue)
                        .font(.system(size: 50, weight:.heavy))
                        .padding([.leading,.trailing], 10)
                        .foregroundColor(.white)
                    Text(countdown.wrappedValue)
                        .font(.system(size: 17))
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
    }
}

//struct HomeScreenView_Preview: PreviewProvider {
//    static var previews: some View {
//        BellScheduleAppView(firstTimeUser: false)
//    }
//}


