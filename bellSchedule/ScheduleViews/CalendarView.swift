//
//  CalendarView.swift
//  BellSchedule
//
//  Created by Ari Stassinopoulos on 2024-09-27.
//

import SwiftUI
import BellScheduleKit

struct CalendarConvenience {
    static func ending(_ selectedDate: Int?) -> String {
        return (selectedDate == nil ? "" : (
            selectedDate == 11 || selectedDate == 12 || selectedDate == 13 ? "th" : (
                selectedDate! % 10 == 1 ? "st" : (
                    selectedDate! % 10 == 2 ? "nd" : (
                        selectedDate! % 10 == 3 ? "rd" : "th"
                    )
                )
            )
        ))}
}


struct CalendarButton: View {
    let date: Int;
    let chooseDate: (Int) -> Void
    let hasSchedule: Bool;
    @Binding var currentSelectedDate: Int?;
    
    var body: some View {
        ZStack {
            if(currentSelectedDate != date) {
                Color(.clear)
                Button(String(date)) {
                    chooseDate(date);
                }.buttonStyle(.borderless).tint(hasSchedule ? .primary : .secondary)
                    .accessibilityHint("Select schedule for the \(date)")
                
            } else {
                Color("AppColor")
                Button(String(date).padding(toLength: 2, withPad: " ", startingAt: 0)) {
                    chooseDate(date);
                }
                .buttonStyle(.borderless).tint(.primary)
                    .accessibilityHint("Select schedule for the \(date). Currently selected.")
            }
        }.frame(minHeight:30.0).clipShape(.circle)
    }
}

struct CalendarButtonRow: View {
    
    let index: Int;
    @Binding var currentSelectedDate: Int?;
    let firstWeekday: Int;
    let lastDate: Int;
    let currentCalendar: [Int: String];
    
    let chooseDate: (Int) -> Void;
    
    var body: some View {
        GridRow {
            ForEach(0..<7) {dayIndex in
                let date = index * 7 + dayIndex - firstWeekday + 2;
                if(date > 0 && date <= lastDate) {
                    CalendarButton(date: date, chooseDate: chooseDate, hasSchedule: currentCalendar[date] != nil, currentSelectedDate: $currentSelectedDate)
                        .accessibilityElement(children:.combine)
                        .accessibilityLabel("\(date)")
                        .accessibilityHint("Select the \(date)\(CalendarConvenience.ending(date))")
                        .frame(maxWidth: .infinity, maxHeight:.infinity);
                } else {
                    Text("").accessibilityHidden(true).frame(maxWidth:.infinity);
                }
            }
        }
    }
    
}


struct CalendarView: View {
    
    @State public var context: BSContext;
    @State var selectedDate: Int? = Calendar.current.component(.day, from: Date());
    let MONTH_NAMES = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    
    
    var body: some View {
        let calendar = context.calendar;
        if let currentCalendar = calendar.monthSchedule(forDate: Date()),
           let firstOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())),
           let firstOfNextMonth = Calendar.current.date(byAdding: .month, value: 1, to: firstOfMonth),
           let lastOfMonth = Calendar.current.date(byAdding: .day, value: -1, to:firstOfNextMonth)
        {
            let today = Calendar.current.component(.day, from: Date())
            let firstWeekday = Calendar.current.component(.weekday, from: firstOfMonth)
            let lastDate = Calendar.current.component(.day, from: lastOfMonth);
            let monthName = MONTH_NAMES[Calendar.current.component(.month, from: Date()) - 1]
            let year = Calendar.current.component(.year, from: Date())
            
            List {
                Section("\(monthName) \(String(year))") {
                    Group {
                        Grid(horizontalSpacing: 0) {
                            ForEach(0..<5) {weekNumber in
                                Group {
                                    CalendarButtonRow(index: weekNumber, currentSelectedDate: $selectedDate, firstWeekday: firstWeekday, lastDate: lastDate, currentCalendar: currentCalendar, chooseDate: { date in
                                        withAnimation {
                                            selectedDate = date;
                                        }
                                    })
                                }
                                
                            }
                        }
                    }.accessibilityElement(children: .contain)
                        .accessibilityLabel("Select a date")
                }
                
                if(selectedDate != nil) {
                    CalendarScheduleView(context: context, currentCalendar: currentCalendar, selectedDate: $selectedDate, lastDate: lastDate, monthName: monthName, today: today)
                        .accessibilityElement(children: .contain)
                }
            }.listStyle(.plain)
                .selectionDisabled()
            
        } else {
            Text("No calendar for this month.")
        }
        
    }
}

struct CalendarScheduleView: View {
    
    @State public var context: BSContext;
    @State public var currentCalendar: [Int: String];
    @Binding public var selectedDate: Int?;
    public let lastDate: Int;
    public let monthName: String;
    public let today: Int;
    
    var body: some View {
        
        if let currentSelectedDate = selectedDate, let currentScheduleID = currentCalendar[currentSelectedDate], let currentSchedule = context.calendar.scheduleTable.schedules[currentScheduleID], currentSchedule.periods.count > 0 {
            let currentSchedulePeriods = currentSchedule.periods.sorted(by: { pleft, pright in
                pright.startTime > pleft.startTime;
            });
            
            Section("Schedule for \(monthName) \(currentSelectedDate)\(CalendarConvenience.ending(currentSelectedDate))") {
                
                CalendarDateControlsView(selectedDate: $selectedDate, lastDate: lastDate);
                
                ForEach (Array(0...currentSchedulePeriods.count - 1), id: \.self) { key in
                    let period = currentSchedulePeriods[key]
                    SchedulePeriodView(period: period, context: context, isCurrent: currentSchedulePeriods[key].isCurrent && currentSelectedDate == today)
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("Schedule for \(monthName) \(currentSelectedDate)\(CalendarConvenience.ending(currentSelectedDate)): \(currentSchedule.displayName)")
            }
            
        } else {
            
            Section("Schedule for \(monthName) \(selectedDate!)\(CalendarConvenience.ending(selectedDate))") {
                CalendarDateControlsView(selectedDate: $selectedDate, lastDate: lastDate);
                Text("No schedule.").accessibilityValue("No schedule for this date.");
            }.accessibilityLabel("Currently selected schedule")
        }
        
    }
    
}

struct CalendarDateControlsView: View {
    @Binding var selectedDate: Int?;
    public let lastDate: Int;
    
    var body: some View {
        HStack {
            Button("Previous") {
                DispatchQueue.main.async {
                    selectedDate! -= 1;
                }                    }.disabled(selectedDate! <= 1)
                .buttonStyle(.bordered)
                .accessibilityHint("Previous day")
            
            Spacer()
            Button("Next") {
                DispatchQueue.main.async {
                    selectedDate! += 1;
                }
            }.disabled(selectedDate! >= lastDate)
                .buttonStyle(.bordered)
                .accessibilityHint("Next day")
            
        }
    }
}
