//
//  HomeScreenWidget.swift
//  HomeScreenWidget
//
//  Created by Ari Stassinopoulos on 2023-05-28.
//

import WidgetKit
import SwiftUI
import BellScheduleKit
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> HomeScreenEntry {
        HomeScreenEntry(date: Date(), configuration: ConfigurationIntent(), family: context.family)
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (HomeScreenEntry) -> ()) {
        let entry = HomeScreenEntry(date: Date(), configuration: configuration, family: context.family)
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [HomeScreenEntry] = [HomeScreenEntry(date: Date.now, configuration: configuration, family: context.family)]
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        if let bsContext = BSContext.fromDefaults,
           let currentSchedule = bsContext.calendar.currentSchedule {
            let periods = currentSchedule.periods;
            periods.forEach { period in
                if let startDate = period.startTime.date {
                    if startDate < Date.now {
                        return;
                    }
                    let entryDate = startDate.addingTimeInterval(1);
                    let entry = HomeScreenEntry(date: entryDate, configuration: configuration, family: context.family)
                    entries.append(entry)
                }
            }
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct HomeScreenEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let family: WidgetFamily
}

struct HomeScreenWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        let date = entry.date;
        var size: Int {
            switch entry.family {
            case .systemLarge, .systemExtraLarge:
                return 1;
            default:
                return 0;
            }
        };
        VStack {
            
            if let context = BSContext.fromDefaults {
                if let currentSchedule = context.calendar.currentSchedule(forDate: date) {
                    if let currentPeriod = currentSchedule.currentPeriod(forDate: date)
                    {
                        Text(context.symbolTable.render(templateString: currentPeriod.name))
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                        Spacer()
                        Text(currentPeriod.startTime.localString)
                            .foregroundColor(.white)
                            .font(.system(size: 17))
                        Text(currentPeriod.endTime.localString)
                            .foregroundColor(.white)
                            .fontWeight(.black)
                            .font(.system(size: size == 0 ? (BSTime.usesAMPM ? 25 : 35) : 40))
                    } else {
                        Spacer()
                        Text("No class")
                            .padding(size == 1 ? .bottom : [])
                            .foregroundColor(.white)
                            .fontWeight(.black)
                            .font(.system(size: 25))
                    }
                    Spacer()
                    if(size == 1) {
                        let periods = currentSchedule.periods.sorted { leftPeriod, rightPeriod in
                            rightPeriod.startTime > leftPeriod.startTime;
                        }.filter { period in
                            if let startDate = period.startTime.date {
                                return startDate > Date.now;
                            }
                            return false;
                        }.prefix(5);
                        VStack {
                            ForEach(periods, id: \.self) { period in
                                let periodName = context.symbolTable.render(templateString: period.name)
                                HStack {
                                    Text(periodName);
                                    Spacer();
                                    Text(period.startTime.localString);
                                    Text("-");
                                    Text(period.endTime.localString);
                                }.padding([.top, .bottom], 1.0)
                                    .foregroundColor(periodName == "Passing Period" ? .gray : .white)
                                    .font(.system(size: 15))
                            }.accessibilityElement(children: .contain)
                        }.padding()
                    }
                    Spacer()
                } else {
                    Spacer()
                    Text("No schedule")
                        .foregroundColor(.white)
                        .fontWeight(.black)
                        .font(.system(size: size == 0 ? 17 : 35))
                        .padding(.bottom)
                    Spacer()
                    
                }
            } else {
                Spacer()
                Text("Failed to load")
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                    .padding(.bottom)
                Spacer()
            }
        }
        .padding([.leading, .trailing],3.0)
        .padding([.top])
        .containerBackground(for: .widget) {
            Color("AppColor")
        }
    }
}


struct HomeScreenWidget: Widget {
    let kind: String = "HomeScreenWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            HomeScreenWidgetEntryView(entry: entry)
        }
    }
}
