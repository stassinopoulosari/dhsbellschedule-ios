//
//  ScheduleView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import SwiftUI
import BellScheduleKit

struct TodayScheduleView: View {
    
    @State public var context: BSContext;
    
    var body: some View {
        if var currentSchedule = context.calendar.currentSchedule, currentSchedule.periods.count > 0 {
            let _ = print("current schedule \(currentSchedule)");
            var currentSchedule = currentSchedule.periods.sorted(by: { pleft, pright in
                pright.startTime > pleft.startTime;
            });
            let _ = print("current schedule \(currentSchedule)");
            List (Array(0...currentSchedule.count - 1), id: \.self) { key in
                let _ = print(currentSchedule[key])
                HStack {
                    Text(currentSchedule[key].name);
                    Spacer();
                    Text(currentSchedule[key].startTime.string);
                    Text("-");
                    Text(currentSchedule[key].endTime.string);
                }
            }
        } else {
            List([0], id: \.self) { _ in
                Text("No schedule.")
            }
        }
        
    }
}
