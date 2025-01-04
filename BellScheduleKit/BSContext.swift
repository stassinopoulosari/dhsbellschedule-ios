//
//  BSContext.swift
//  BellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-28.
//

import Foundation

/// Context observer
/// Weird and off-putting class I need to use to make the Context observable
public class BSContextObserver: ObservableObject {
    
    /// The current period from the Context
    @Published public var currentPeriod: BSPeriod?;
    /// The countdown time to display on the Homescreen (or -1 if that's not applicable)
    @Published public var countdownTime: Int = -1;
    /// The String representation of `countdownTime`
    @Published public var countdownTimeString: String = "";
    /// The String to show on the home screen for the start time
    @Published public var startTimeString: String = "";
    /// The String to show on the home screen for the end time
    @Published public var endTimeString: String = "Loading";
    /// The String to show on the home screen for the class name
    @Published public var classNameString: String = "";
    /// The context from which we are pulling this all from
    private var context: BSContext;
    /// Timer we use to count down
    private var timer: Timer?
    
    ///Initializer
    ///- Parameter withContext: The context to use in the ContextObserver
    public init(withContext context: BSContext) {
        self.context = context;
        // Schedule a timer for every second for the refresh
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.refresh();
        })
        // Refresh now
        self.refresh();
    }
    deinit {
        // If you don't do this, the app will crash when it backgrounds (ask me how I know)
        timer?.invalidate()
    }
    func refresh() {
        // Pull all of our values from the context
        if let schedule = context.calendar.currentSchedule {
            currentPeriod = schedule.currentPeriod;
            if let currentPeriod = currentPeriod,
               let endDate = currentPeriod.endTime.date {
                let currentDate = Date.now;
                // Make the countdown timer
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

/// BSContext
/// Representation of all of the loaded data of the Bell Schedule
public class BSContext: ObservableObject {
    
    /// Representation of where the context came from
    public enum BSContextOrigin {
        case network
        case cache
    }
    
    /// Create a `BSContext`
    /// - Parameter calendar
    /// - Parameter symbolTable
    /// - Parameter origin: Cache or network
    /// - Parameter lastUpdated: Date the Context was last saved or created on the network
    /// - Parameter zeroPeriodSymbol: Symbol used for "Period 0"
    public init(
        calendar: BSCalendar,
        symbolTable: BSSymbolTable,
        origin: BSContextOrigin,
        lastUpdated: Date,
        zeroPeriodSymbol: String
    ) {
        self.calendar = calendar;
        self.symbolTable = symbolTable;
        self.origin = origin;
        self.lastUpdated = lastUpdated;
        self.zeroPeriodSymbol = zeroPeriodSymbol
    }
    
    /// Saved context, or `nil` if one does not exist
    public static var fromDefaults: BSContext? {
        if let savedContext = BSPersistence.loadContext() {
            return savedContext;
        }
        return nil
    }
    
    /// Save custom schedules on this `Context`
    public func saveCustomSchedules() {
        BSPersistence.save(contextWithUpdatedCustomSymbols: self);
    }
    
    /// Calendar of schedules
    @Published public var calendar: BSCalendar;
    /// Symbol table for this Context
    @Published public var symbolTable: BSSymbolTable;
    /// Origin of this context (cache or network)
    @Published public var origin: BSContextOrigin;
    /// When was this context last updated
    @Published public var lastUpdated: Date;
    /// What is the symbol for "Period 0" for this context
    @Published public var zeroPeriodSymbol: String;
}

/// Wrapper for loading the Context
public class BSContextLoader: ObservableObject {
    public enum BSContextLoaderState {
        case loading
        case loadedWithoutErrors
        case loadedWithErrors([Error])
        case failed([Error])
    }
    
    @Published public var context: BSContext?;
    @Published public var state: BSContextLoaderState;
    
    /// `true` if the context is not yet renderable
    public var hasNoValidContext: Bool {
        switch state {
        case .loadedWithoutErrors, .loadedWithErrors(_):
            return false;
        case .failed(_), .loading:
            return true;
        }
    };
    
    private init(state: BSContextLoaderState) {
        self.context = nil;
        self.state = state;
    }
    
    /// Initialize a BSContextLoader
    /// - Parameter databaseReference: Firebase reference, or `nil` if we have no network
    /// - Parameter onload: Callback to call once the ContextLoader has loaded
    public static func make(
        onload: @escaping() -> Void
    ) -> BSContextLoader {
        let returnValue = BSContextLoader(state: .loading);
        BSCompatibility.convert();
        BSKit.getNewestContext { currentContext, errors in
            if let currentContext = currentContext {
                DispatchQueue.main.async {
                    returnValue.context = currentContext;
                    print(currentContext.origin);
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
