//
//  AllScheduleView.swift
//  bellSchedule
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import SwiftUI
import BellScheduleKit

struct AllScheduleView: View {
    
    @ObservedObject public var context: BSContext;
    
    var body: some View {
        let schedules = context.calendar.scheduleTable.schedules;
        let currentSchedule = context.calendar.currentSchedule;
        
        let scheduleKeys = schedules.keys.sorted { leftKey, rightKey in
            if let leftSchedule = schedules[leftKey], let rightSchedule = schedules[rightKey] {
                if let currentSchedule = currentSchedule {
                    if leftSchedule.name == currentSchedule.name {
                        return true;
                    } else if rightSchedule.name == currentSchedule.name {
                        return false;
                    }
                }
                return leftSchedule.name < rightSchedule.name;
            }
            return true;
        };
        
        List {
            ForEach(scheduleKeys, id: \.self) { scheduleKey in
                if let schedule = schedules[scheduleKey] {
                    Section(header:Text("\(schedule.displayName)\(currentSchedule != nil && currentSchedule!.name == schedule.name ? " (CURRENT)" : "")").bold()) {
                        let periods = schedule.periods;
                        let periodIndices: [Int] = Array(0..<periods.count);
                        ForEach(periodIndices, id: \.self){ periodIdx in
                            SchedulePeriodView(period: periods[periodIdx], context: context, isCurrent: currentSchedule != nil && currentSchedule!.name == schedule.name && periods[periodIdx].isCurrent);
                        }
                    }
                }
            }
        }.listStyle(.grouped)
    }
}

//struct AllScheduleView_Previews: PreviewProvider {
//    static var previews: some View {
//        AllScheduleView()
//    }
//}
