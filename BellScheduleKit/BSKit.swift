//
//  Schedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import Foundation
import FirebaseCore
import FirebaseDatabase



public struct BSKit {
    
    enum BSKitError: Error {
        case noSavedContextAndNoDBReference
    }
    
    public static func leftPad(_ string: String, toLength target: Int, withString substring: any StringProtocol) -> String {
        var outputString = string;
        while(outputString.count < target) {
            outputString = substring + outputString;
        }
        return outputString;
    }
    
    public static func getNewestContext(withDatabaseReference databaseReference: DatabaseReference?, callback: @escaping (_ currentContext: BSContext?, _ errors: [Error]) -> Void) {
        
        if let databaseReference = databaseReference {
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
        } else {
            if let savedContext = BSPersistence.loadContext() {
                return callback(
                    savedContext,
                    []
                );
            } else {
                return callback(
                    nil,
                    [BSKitError.noSavedContextAndNoDBReference]
                );
            }
        }
    }
}


