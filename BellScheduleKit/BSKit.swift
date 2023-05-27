//
//  Schedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public class BSContext {
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
    
    public func saveCustomSchedules() {
        BSPersistence.save(softUpdateOfContext: self);
    }
    
    public var calendar: BSCalendar;
    public var symbolTable: BSSymbolTable;
    public var type: BSContextType;
    public var lastUpdated: Date;
}

public class BSContextWrapper: ObservableObject {
    public enum BSContextWrapperState {
        case loading
        case loadedWithoutErrors
        case loadedWithErrors([Error])
        case failed([Error])
    }
    
    public var context: BSContext?;
    public var state: BSContextWrapperState;
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
        BSKit.getNewestContext(withDatabaseReference: databaseReference) { currentContext, errors in
            if let currentContext = currentContext {
                returnValue.context = currentContext;
                if errors.count == 0 {
                    returnValue.state = .loadedWithoutErrors
                    return;
                }
                returnValue.state = .loadedWithErrors(errors);
                return;
            }
        }
        return returnValue;
    }
}



public struct BSKit {
    public static func getNewestContext(withDatabaseReference databaseReference: DatabaseReference?, callback: @escaping (_ currentContext: BSContext?, _ errors: [Error]) -> Void) {
        let network = BSNetwork(databaseReference: databaseReference);
        network.checkLastUpdated(callback: {networkLastUpdated in
            if let persistenceLastUpdated = BSPersistence.contextLastUpdated,
               let savedContext = BSPersistence.loadContext(),
               persistenceLastUpdated > networkLastUpdated {
                return callback(
                    savedContext,
                    []
                );
            }
            network.downloadContext(callback: { networkContext in
                BSPersistence.save(hardUpdateOfContext: networkContext)
                return callback(
                    networkContext,
                    []
                );
            }, error: {errors in
                if let savedContext = BSPersistence.loadContext() {
                    return callback(
                        savedContext,
                        errors
                    );
                } else {
                    return callback(
                        nil,
                        errors
                    );
                }
            })
        }, errorCallback: {
            error in
            if let savedContext = BSPersistence.loadContext() {
                return callback(
                    savedContext,
                    [error]
                );
            } else {
                return callback(
                    nil,
                    [error]
                );
            }
        });
    }
}

