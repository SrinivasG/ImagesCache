//
//  Reachability.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import Foundation
import Network

// An enum to handle the network status
enum NetworkStatus {
    case connected
    case disconnected
}

class NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "Monitor")
    
    var status: NetworkStatus = .connected
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            
            if path.status == .satisfied {
                self.status = .connected
                
            } else {
                self.status = .disconnected
            }
        }
        monitor.start(queue: queue)
    }
}

