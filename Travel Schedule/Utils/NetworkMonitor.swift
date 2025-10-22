//
//  NetworkMonitor.swift
//  Travel Schedule
//
//  Created by Ульта on 23.10.2025.
//

import Foundation
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected = true
    @Published var connectionStatusChanged = false
    
    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                let isNowConnected = path.status == .satisfied
                
                self?.isConnected = isNowConnected
                
                // Уведомляем об изменении статуса
                if wasConnected != isNowConnected {
                    self?.connectionStatusChanged = true
                    // Сбрасываем флаг через небольшую задержку
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.connectionStatusChanged = false
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}
