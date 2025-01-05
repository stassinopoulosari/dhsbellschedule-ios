//
//  BSNetwork.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-26.
//

import Foundation

public struct BSDatabaseAbstraction {
    enum BSDatabaseAbstractionError: Error {
        case nilDataError
    }
    enum BSDatabaseExpectedDataType {
        case string
        case int
        case dict
    }
    
    private let abstractionData: [String: Any];
    
    private init(withData data: [String: Any]) {
        self.abstractionData = data;
    }
    
    static func create(_ callback: @escaping((any Error)?, BSDatabaseAbstraction?) -> Void) {
        let networkPath = "https://ubsa-replicate.ari-s.com/dublinHS.json";
        if let networkURL = URL(string: networkPath) {
            let networkTask = URLSession.shared.dataTask(with: networkURL) { data, response, error in
                if let error = error {
                    return callback(error, nil);
                }
                if let data = data {
                    do {
                        let parsedData = try JSONSerialization.jsonObject(with: data)
                        return callback(nil, BSDatabaseAbstraction(withData: parsedData as! [String: Any]));
                    } catch let parseError {
                        return callback(parseError, nil)
                    }
                } else {
                    return callback(BSDatabaseAbstractionError.nilDataError, nil);
                }
            }
            networkTask.resume()
        }
    }
    
    func getData(withPath: String) -> Any? {
        if let data = abstractionData[withPath] {
            return data;
        }
        return nil;
    }
}

public struct BSNetwork {
    
    private let calendarPath = "calendars"
    private let scheduleTablePath = "schedules"
    private let symbolsPath = "symbols"
    private let lastUpdatedPath = "lastUpdated"
    private let zeroPeriodSymbolPath = "zeroPeriodSymbol"
    
    enum BSNetworkError: Error {
        case databaseReferenceIsNil
        case unexpectedValueType
        case databaseFailToAccess
        case unableToConstructContext
    }
    
    /// Check last updated
    /// - Parameter callback: Callback to call if the check succeeds, with a `Date` representation of the last update.
    /// - Parameter fail: Callback to call if the check fails, with an `Error` describing what happened.
    func checkLastUpdated(callback: @escaping (Date) -> Void,  fail errorCallback: @escaping (Error) -> Void) {
        BSDatabaseAbstraction.create { (error, abstraction) in
            if let error = error {
                return errorCallback(error)
            }
            if let abstraction = abstraction {
                if let valueInt = abstraction.getData(withPath: lastUpdatedPath) as? Int {
                    print(Date(
                        timeIntervalSince1970: TimeInterval(valueInt)
                    ))
                    return callback(
                        Date(
                            timeIntervalSince1970: TimeInterval(valueInt)
                        )
                    );
                } else {
                    return errorCallback(BSNetworkError.unexpectedValueType);
                }
            } else {
                return errorCallback(BSNetworkError.databaseFailToAccess)
            }
        }
    }
    
    /// Download the context
    /// - Parameter callback: Callback to call if the download succeeds, with the `BSContext` from the server.
    /// - Parameter fail: Callback to call if the download fails, with an `Error` describing what happened.
    func remoteContext(
        callback: @escaping (BSContext) -> Void,
        fail errorCallback: @escaping ([Error]) -> Void
    ) {
        BSDatabaseAbstraction.create { (error, abstraction) in
            if let error = error {
                return errorCallback([error]);
            }
            if let abstraction = abstraction {
                var scheduleTableObject: [String: Any]?;
                var calendarObject: [String: Any]?;
                var symbolsObject: [String: Any]?;
                var zeroPeriodSymbol: String?;
                var errors = [Error]();
                
                //        group.enter()
                if let value = abstraction.getData(withPath: symbolsPath),
                   let valueObject = value as? [String: Any]{
                    symbolsObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                //            return group.leave()
                
                //        group.enter()
                if let value = abstraction.getData(withPath: scheduleTablePath),
                   let valueObject = value as? [String: Any]{
                    scheduleTableObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                //            return group.leave()
                
                //        group.enter()
                if let value = abstraction.getData(withPath: calendarPath),
                   let valueObject = value as? [String: Any]{
                    calendarObject = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                //            return group.leave()
                
                //        group.enter()
                
                if let value = abstraction.getData(withPath: zeroPeriodSymbolPath),
                   let valueObject = value as? String{
                    zeroPeriodSymbol = valueObject;
                } else {
                    errors.append(BSNetworkError.unexpectedValueType);
                }
                
                
                //        group.notify(queue: .global()) {
                if(errors.count > 0) {
                    return errorCallback(errors);
                }
                
                if let scheduleTableObject = scheduleTableObject,
                   let calendarObject = calendarObject,
                   let symbolsObject = symbolsObject,
                   let zeroPeriodSymbol = zeroPeriodSymbol {
                    var symbolTable = BSSymbolTable.from(dictionary: symbolsObject);
                    if let customSymbols = BSPersistence.loadCustomSymbols() {
                        symbolTable.register(customSymbols: customSymbols);
                    }
                    let scheduleTable = BSScheduleTable.from(dictionary: scheduleTableObject)
                    return callback(
                        BSContext(
                            calendar: BSCalendar.from(
                                dictionary: calendarObject,
                                withScheduleTable: scheduleTable
                            ),
                            symbolTable: symbolTable,
                            origin: .network,
                            lastUpdated: Date.now,
                            zeroPeriodSymbol: zeroPeriodSymbol
                        )
                    );
                } else {
                    return errorCallback([BSNetworkError.unableToConstructContext]);
                }
            } else {
                return errorCallback([BSNetworkError.databaseFailToAccess])
            }
        }
    }
}

