//
//  BSNetwork.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-26.
//

import Foundation

private struct BSDatabaseAbstraction {
    enum BSDatabaseAbstractionError: Error {
        case nilDataError
    }
    enum BSDatabaseExpectedDataType {
        case string
        case int
        case dict
    }
    private static let baseURL = "https://ubsa-fb.firebaseio.com";
    
    private static func constructNetworkPath(withPath path: String) -> String {
        return "\(baseURL)/\(path).json?ts=\(Date().timeIntervalSince1970)";
    }
    
    static func getData(withPath path: String, expectedType: BSDatabaseExpectedDataType = .dict,_ callback: @escaping ((any Error)?, Any?) -> Void) {
        let networkPath: String = constructNetworkPath(withPath: path)
        if let networkURL = URL(string: networkPath) {
            print("Creating network task with url \(networkURL)")
            let networkTask = URLSession.shared.dataTask(with: networkURL) { data, response, error in
                print("Network task completed \(data != nil ? "with data" : "without data"), \(error != nil ? "with error" : "without error")")
                if let error = error {
                    return callback(error, nil);
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    do {
                        print("Data: \(dataString)")
                        switch expectedType {
                        case .dict:
                            let parsedData = try JSONSerialization.jsonObject(with: data)
                            return callback(nil, parsedData);
                        case .int:
                            let parsedData = Int(dataString)
                            return callback(nil, parsedData);
                        case .string:
                            return callback(nil, dataString.trimmingCharacters(in: CharacterSet(charactersIn: "\"")))
                        }
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
}

public struct BSNetwork {
    
    private let calendarPath = "schools/dublinHS/calendars"
    private let scheduleTablePath = "schools/dublinHS/schedules"
    private let symbolsPath = "schools/dublinHS/symbols"
    private let lastUpdatedPath = "schools/dublinHS/lastUpdated"
    private let zeroPeriodSymbolPath = "schools/dublinHS/zeroPeriodSymbol"
    
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
        BSDatabaseAbstraction.getData(withPath: lastUpdatedPath, expectedType: .int) { (error, data) in
            if let error = error {
                return errorCallback(error);
            }
            if let valueInt = data as? Int {
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
        }
    }
    
    /// Download the context
    /// - Parameter callback: Callback to call if the download succeeds, with the `BSContext` from the server.
    /// - Parameter fail: Callback to call if the download fails, with an `Error` describing what happened.
    func remoteContext(
        callback: @escaping (BSContext) -> Void,
        fail errorCallback: @escaping ([Error]) -> Void
    ) {
        // Use a DispatchGroup to dispatch all of these at the same time
        let group = DispatchGroup()
        var scheduleTableObject: [String: Any]?;
        var calendarObject: [String: Any]?;
        var symbolsObject: [String: Any]?;
        var zeroPeriodSymbol: String?;
        var errors = [Error]();
        
        group.enter()
        BSDatabaseAbstraction.getData(withPath: symbolsPath) {(error, value) in
            if let error = error {
                errors.append(error);
                return group.leave();
            }
            if let value = value,
               let valueObject = value as? [String: Any]{
                symbolsObject = valueObject;
            } else {
                errors.append(BSNetworkError.unexpectedValueType);
            }
            return group.leave()
        }
        
        group.enter()
        BSDatabaseAbstraction.getData(withPath: scheduleTablePath) {(error, value) in
            if let error = error {
                errors.append(error);
                return group.leave();
            }
            if let value = value,
               let valueObject = value as? [String: Any]{
                scheduleTableObject = valueObject;
            } else {
                errors.append(BSNetworkError.unexpectedValueType);
            }
            return group.leave()
        }
        
        group.enter()
        BSDatabaseAbstraction.getData(withPath: calendarPath) {(error, value) in
            if let error = error {
                errors.append(error);
                return group.leave();
            }
            if let value = value,
               let valueObject = value as? [String: Any]{
                calendarObject = valueObject;
            } else {
                errors.append(BSNetworkError.unexpectedValueType);
            }
            return group.leave()
        }
        
        group.enter()
        BSDatabaseAbstraction.getData(withPath: zeroPeriodSymbolPath, expectedType: .string) {(error, value) in
            if let error = error {
                errors.append(error);
                return group.leave();
            }
            if let value = value,
               let valueObject = value as? String{
                zeroPeriodSymbol = valueObject;
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
        }
    }
}

