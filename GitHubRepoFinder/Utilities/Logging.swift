//
//  Logging.swift
//  GitHubRepoFinder
//
//  Created by Andrew Struck-Marcell on 8/14/22.
//

import Foundation
import os.log

enum Logging {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.astruckmarcell.GitHubRepoFinder"
    private static let networkingCategory = "Networking"
    private static let coreDataCategory = "CoreData"
    
    static func logNetworkingError(message: String) {
        let log = OSLog(subsystem: Self.subsystem, category: Self.networkingCategory)
        os_log("%{public}@", log: log, type: .error, message)
    }
    
    static func logNetworkingUpdate(publicMessage: String = "", privateMessage: String = "") {
        let log = OSLog(subsystem: Self.subsystem, category: Self.networkingCategory)
        let publicMsg = privateMessage.isEmpty ? publicMessage : (publicMessage + " ")
        os_log("%{public}@%{private}@", log: log, type: .info, publicMsg, privateMessage)
    }
    
    static func logCoreDataError(message: String) {
        let log = OSLog(subsystem: Self.subsystem, category: Self.coreDataCategory)
        os_log("%{public}@", log: log, type: .error, message)
    }

}
