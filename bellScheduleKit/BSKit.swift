//
//  Schedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import Foundation

public struct BSContext {
    public enum BSContextType {
        case network
        case cache
    }
    public var calendar: BSCalendar;
    public var symbolTable: BSSymbolTable;
    public var type: BSContextType;
    public var lastUpdated: Date;
}



public struct BSKit {
    public static func getNewestContext(callback: (_ currentContext: BSContext?, _ error: Error?) -> Void) {
        let network = BSNetwork(),
            persistence = BSPersistence();
        network.checkLastUpdated(callback: {networkLastUpdated in
            if let persistenceLastUpdated = persistence.contextLastUpdated,
               let savedContext = persistence.load(),
               persistenceLastUpdated > networkLastUpdated {
                return callback(
                    savedContext,
                    nil
                );
            }
            network.downloadContext(callback: { networkContext in
                persistence.save(context: networkContext)
                return callback(
                    networkContext,
                    nil
                );
            }, error: {error in
                if let savedContext = persistence.load() {
                    return callback(
                        savedContext,
                        error
                    );
                } else {
                    return callback(
                        nil,
                        error
                    );
                }
            })
        }, error: {
            error in
            if let savedContext = persistence.load() {
                return callback(
                    savedContext,
                    error
                );
            } else {
                return callback(
                    nil,
                    error
                );
            }
        });
    }
}

