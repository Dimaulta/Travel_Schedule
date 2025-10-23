//
//  SessionManager.swift
//  Travel Schedule
//
//  Created by Ульта on 23.10.2025.
//

import Foundation
import SwiftUI

class SessionManager: ObservableObject {
    @Published var fromCity: String? = nil
    @Published var fromStation: String? = nil
    @Published var toCity: String? = nil
    @Published var toStation: String? = nil
    
    func clearSession() {
        fromCity = nil
        fromStation = nil
        toCity = nil
        toStation = nil
    }
    
    func hasValidRoute() -> Bool {
        return fromCity != nil && fromStation != nil && toCity != nil && toStation != nil
    }
}
