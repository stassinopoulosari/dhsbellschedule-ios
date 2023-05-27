//
//  BSNetwork.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-26.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

public struct BSNetwork {
    
    private let calendarPath = "schools/dublinHS/calendars"
    private let scheduleTablePath = "schools/dublinHS/schedules"
    private let symbolsPath = "schools/dublinHS/symbols"
    private let lastUpdatedPath = "schools/dublinHS/lastUpdated"
    
    enum BSNetworkError: Error {
        case databaseReferenceIsNil
        case unexpectedValueType
        case databaseFailToAccess
        case unableToConstructContext
    }
    
    public let databaseReference: DatabaseReference?;
    
    func checkLastUpdated( callback: @escaping (Date) -> Void,  errorCallback: @escaping (Error) -> Void) {
        if let databaseReference = databaseReference {
            databaseReference.child(lastUpdatedPath).getData { (error, snapshot) in
                if let error = error {
                    return errorCallback(error);
                }
                if let snapshot = snapshot,
                   let value = snapshot.value,
                   let valueInt = value as? Int{
                    return callback(Date(timeIntervalSince1970: TimeInterval(valueInt)))
                } else {
                    return errorCallback(BSNetworkError.unexpectedValueType);
                }
            }
        } else {
            return errorCallback(BSNetworkError.databaseReferenceIsNil)
        }
    }
    
    func downloadContext( callback: @escaping (BSContext) -> Void, error errorCallback: @escaping ([Error]) -> Void) {
        if let databaseReference = databaseReference {
            let group = DispatchGroup()
            var scheduleTableObject: [String: Any]?;
            var calendarObject: [String: Any]?;
            var symbolsObject: [String: Any]?;
            var errors = [Error]();
            
            group.enter()
            databaseReference.child(symbolsPath).getData { (error, snapshot) in
                if let error = error {
                    errors.append(error);
                    return group.leave();
                }
                if let snapshot = snapshot,
                   let value = snapshot.value,
                   let valueObject = value as? [String: Any]{
                    symbolsObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                return group.leave()
            }
            
            group.enter()
            databaseReference.child(scheduleTablePath).getData { (error, snapshot) in
                if let error = error {
                    errors.append(error);
                    return group.leave();
                }
                if let snapshot = snapshot,
                   let value = snapshot.value,
                   let valueObject = value as? [String: Any]{
                    scheduleTableObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                return group.leave()
            }
            
            group.enter()
            databaseReference.child(calendarPath).getData { (error, snapshot) in
                if let error = error {
                    errors.append(error);
                    return group.leave();
                }
                if let snapshot = snapshot,
                   let value = snapshot.value,
                   let valueObject = value as? [String: Any]{
                    calendarObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                return group.leave()
            }
            
            group.notify(queue: .global()) {
                if(errors.count > 0) {
                    return errorCallback(errors);
                }
                
                if let scheduleTableObject = scheduleTableObject,
                   let calendarObject = calendarObject,
                   let symbolsObject = symbolsObject {
                    var symbolTable = BSSymbolTable.from(dictionary: symbolsObject);
                    if let defaults = BSPersistence.defaults {
                        symbolTable.register(customSymbols: BSPersistence().loadCustomSymbols(fromDefaults: defaults));
                    }
                    let scheduleTable = BSScheduleTable.from(dictionary: scheduleTableObject)
                    return callback(BSContext(calendar: BSCalendar.from(dictionary: calendarObject, withScheduleTable: scheduleTable), symbolTable: symbolTable, type: .network, lastUpdated: Date.now));
                } else {
                    return errorCallback([BSNetworkError.unableToConstructContext]);
                }
            }
        } else {
            return errorCallback([BSNetworkError.databaseReferenceIsNil]);
        }
    }
}
