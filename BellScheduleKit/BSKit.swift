//
//  Schedule.swift
//  bellScheduleKit
//
//  Created by Ari Stassinopoulos on 2023-05-14.
//

import Foundation

/// Main class for the Kit
public struct BSKit {
    
    enum BSKitError: Error {
        /// No saved context and no Database reference.
        case noSavedContextAndNoDBReference
    }
    
    /// Left Pad a string
    /// - Parameter string: String to left-pad
    /// - Parameter toLength: Length to pad `string` to
    /// - Parameter withString: What to pad the original string with
    public static func leftPad(_ string: String, toLength target: Int, withString substring: any StringProtocol) -> String {
        var outputString = string;
        while(outputString.count < target) {
            outputString = substring + outputString;
        }
        return outputString;
    }
    
    /// Get the newest context
    /// - Parameter callback: Callback on completion. We pass a `BSContext` if we are able to make one, or `nil` if we are not. We also pass an array of `Error`s if we generate any.
    public static func getNewestContext(
        callback: @escaping (_ currentContext: BSContext?, _ errors: [Error]) -> Void
    ) {
        // Create an instance of the Network class to download the remote values
        let network = BSNetwork();
        network.checkLastUpdated(success: {networkLastUpdated in
            print(networkLastUpdated);
            // If we have downloaded the Context since the last update on the remote end, we don't need to do it again
            if let persistenceLastUpdated = BSPersistence.contextLastUpdated,
               let savedContext = BSPersistence.loadContext(),
               persistenceLastUpdated > networkLastUpdated {
                print(persistenceLastUpdated)
                return callback(
                    savedContext,
                    []
                );
            }
            // If we do need to download the context, now would be a good time to do it
            network.remoteContext(success: { networkContext in
                // Save the remote context so we don't download it again until the next update
                BSPersistence.save(hardUpdateOfContext: networkContext)
                print("Downloaded context");
                return callback(
                    networkContext,
                    []
                );
            }, fail: {errors in
                print(errors);
                // If we can't download it, try and use the saved context
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
        }, fail: {
            error in
            print(error);
            // If we can't check the last updated, try and use the saved context
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


