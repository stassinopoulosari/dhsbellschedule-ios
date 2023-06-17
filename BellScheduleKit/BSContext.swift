//
//  BSContext.swift
//  BellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-28.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public class BSContextObserver: ObservableObject {
    @Published public var currentPeriod: BSPeriod?;
    @Published public var countdownTime: Int = -1;
    @Published public var countdownTimeString: String = "";
    @Published public var startTimeString: String = "";
    @Published public var endTimeString: String = "Loading";
    @Published public var classNameString: String = "";
    var context: BSContext;
    
    var timer: Timer?
    public init(withContext context: BSContext) {
        self.context = context;
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.refresh();
        })
        self.refresh();
    }
    deinit {
        timer?.invalidate()
    }
    func refresh() {
        if let schedule = context.calendar.currentSchedule {
            currentPeriod = schedule.currentPeriod;
            if let currentPeriod = currentPeriod,
               let endDate = currentPeriod.endTime.date {
                let currentDate = Date.now;
                let distance = Int(floor(abs(endDate.distance(to: currentDate))));
                self.countdownTime = distance;
                let hoursLeft = countdownTime / 60 / 60;
                let minutesLeft = BSKit.leftPad(String((countdownTime / 60) % 60), toLength: 2, withString: "0");
                let secondsLeft = BSKit.leftPad(String(countdownTime % 60), toLength: 2, withString: "0");
                if(hoursLeft > 0) {
                    countdownTimeString = "\(hoursLeft):\(minutesLeft):\(secondsLeft)"
                } else {
                    countdownTimeString = "\(minutesLeft):\(secondsLeft)"
                }
                self.startTimeString = currentPeriod.startTime.localString;
                self.endTimeString = currentPeriod.endTime.localString;
                self.classNameString = context.symbolTable.render(templateString: currentPeriod.name);
            } else {
                
                self.countdownTime = -1;
                self.countdownTimeString = "";
                self.startTimeString = "";
                self.endTimeString = "No class";
                self.classNameString = "";
            }
        } else {
            self.countdownTime = -1;
            self.countdownTimeString = "";
            self.startTimeString = "";
            self.endTimeString = "No schedule";
            self.classNameString = "";
        }
    }
}

public class BSContext: ObservableObject {
    public enum BSContextType {
        case network
        case cache
    }
    
    public init(calendar: BSCalendar, symbolTable: BSSymbolTable, type: BSContextType, lastUpdated: Date) {
        self.calendar = calendar;
        self.symbolTable = symbolTable;
        self.type = type;
        self.lastUpdated = lastUpdated;
    }
    
    public static var fromDefaults: BSContext? {
        if let savedContext = BSPersistence.loadContext() {
            return savedContext;
        }
        return nil
    }
    
    public func saveCustomSchedules() {
        BSPersistence.save(softUpdateOfContext: self);
    }
    
    @Published public var calendar: BSCalendar;
    @Published public var symbolTable: BSSymbolTable;
    @Published public var type: BSContextType;
    @Published public var lastUpdated: Date;
}

public class BSContextWrapper: ObservableObject {
    public enum BSContextWrapperState {
        case loading
        case loadedWithoutErrors
        case loadedWithErrors([Error])
        case failed([Error])
    }
    
    @Published public var context: BSContext?;
    @Published public var state: BSContextWrapperState;
    
    public var done: Bool {
        switch state {
        case .loading:
            return true;
        case .loadedWithoutErrors, .loadedWithErrors(_):
            return false;
        case .failed(_):
            return true;
        }
    };
    
    private init(state: BSContextWrapperState) {
        self.context = nil;
        self.state = state;
    }
    
    public static func from(databaseReference: DatabaseReference?, onload: @escaping() -> Void) -> BSContextWrapper {
        let returnValue = BSContextWrapper(state: .loading);
        BSCompatibility.convert();
        BSKit.getNewestContext(withDatabaseReference: databaseReference) { currentContext, errors in
//            print(currentContext, errors);
            if let currentContext = currentContext {
                DispatchQueue.main.async {
                    returnValue.context = currentContext;
                    print(currentContext.type);
                }
                if errors.count == 0 {
                    DispatchQueue.main.async {
                        returnValue.state = .loadedWithoutErrors
                    }
                    return onload();
                }
                DispatchQueue.main.async {
                    returnValue.state = .loadedWithErrors(errors);
                }
                return onload();
            } else {
                DispatchQueue.main.async {
                    returnValue.state = .failed(errors);
                }
                return onload();
            }
        }
        return returnValue;
    }
}
