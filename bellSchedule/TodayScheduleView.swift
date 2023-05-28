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
        if let currentSchedule = context.calendar.currentSchedule, currentSchedule.periods.count > 0 {
            let currentSchedulePeriods = currentSchedule.periods.sorted(by: { pleft, pright in
                pright.startTime > pleft.startTime;
            });
            List (Array(0...currentSchedulePeriods.count - 1), id: \.self) { key in
                SchedulePeriodView(period: currentSchedulePeriods[key], context: context, isCurrent: currentSchedulePeriods[key].isCurrent);
            }.listStyle(.plain)
        } else {
            List([0], id: \.self) { _ in
                Text("No schedule.")
            }.listStyle(.grouped)
        }
        
    }
}
