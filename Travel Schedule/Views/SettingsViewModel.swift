//
//  SettingsViewModel.swift
//  Travel Schedule
//
//  Created by Ульта on 16.11.2025.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    @AppStorage("isDarkModeEnabled") var isDarkModeEnabled: Bool = false

    func resetStoriesViewed() {
        NotificationCenter.default.post(name: Notification.Name("storiesViewedReset"), object: nil)
    }
}


