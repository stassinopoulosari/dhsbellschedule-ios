//
//  Schedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

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
            print("In context");
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
                print(errors);
                return onload();
            }
        }
        return returnValue;
    }
}



public struct BSKit {
    public static func getNewestContext(withDatabaseReference databaseReference: DatabaseReference?, callback: @escaping (_ currentContext: BSContext?, _ errors: [Error]) -> Void) {
        let network = BSNetwork(databaseReference: databaseReference);
        
        network.checkLastUpdated(callback: {networkLastUpdated in
            print(networkLastUpdated);
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
                print("Downloaded context");
                return callback(
                    networkContext,
                    []
                );
            }, error: {errors in
                print(errors);
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


