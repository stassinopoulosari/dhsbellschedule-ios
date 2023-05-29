//
//  SchedulePeriodView.swift
//  BellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-27.
//

import BellScheduleKit
import SwiftUI

struct SchedulePeriodView: View {
    public var period: BSPeriod;
    public var context: BSContext;
    public var isCurrent: Bool = false;
    
    var body: some View {
            HStack {
                Text(context.symbolTable.render(templateString: period.name))
                    .bold(isCurrent);
                Spacer();
                Text(period.startTime.localString)
                    .bold(isCurrent);
                Text("-")
                    .bold(isCurrent);
                Text(period.endTime.localString)
                    .bold(isCurrent);
            }.listRowBackground(isCurrent ? Color.black : nil)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(context.symbolTable.render(templateString: period.name)). Start \(period.startTime.localString). End \(period.endTime.localString)");
    }
}
