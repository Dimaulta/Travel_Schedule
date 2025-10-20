//
//  CarriersViewModel.swift
//  Travel Schedule
//
//  Created by Ульта on 20.10.2025.
//

import Foundation
import SwiftUI
import OpenAPIURLSession

// MARK: - Модель для отображения рейса
struct TripInfo: Identifiable {
    let id = UUID()
    let carrier: CarrierInfo
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let date: String
    let hasTransfers: Bool
    let transferInfo: String?
}

struct CarrierInfo {
    let title: String
    let logo: String?
    let code: Int?
}

@MainActor
class CarriersViewModel: ObservableObject {
    @Published var trips: [TripInfo] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let searchService: SearchService
    private let apikey = "50889f83-e54c-4e2e-b9b9-7d5fe468a025"
    
    init() {
        let client = Client(
            serverURL: URL(string: "https://api.rasp.yandex.net")!,
            transport: URLSessionTransport()
        )
        self.searchService = SearchService(client: client)
    }
    
    func loadTrips(from: String, to: String, fromStation: String, toStation: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let segments = try await searchService.getSegments(
                apikey: apikey,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                transport_types: "train" // Только поезда
            )
            
            await processSegments(segments)
        } catch {
            errorMessage = "Ошибка загрузки рейсов: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    private func processSegments(_ segments: Segments) async {
        guard let segmentsArray = segments.segments else {
            errorMessage = "Рейсы не найдены"
            return
        }
        
        trips = segmentsArray.compactMap { segment -> TripInfo? in
            guard let departure = segment.departure,
                  let arrival = segment.arrival,
                  let duration = segment.duration,
                  let thread = segment.thread,
                  let carrier = thread.carrier else {
                return nil
            }
            
            // Форматируем время
            let departureTime = formatTime(departure)
            let arrivalTime = formatTime(arrival)
            let durationText = formatDuration(duration)
            
            // Получаем информацию о перевозчике
            let carrierInfo = CarrierInfo(
                title: carrier.title ?? "Неизвестный перевозчик",
                logo: carrier.logo,
                code: carrier.code
            )
            
            // Проверяем наличие пересадок
            let hasTransfers = false // Поле has_transfers недоступно в текущей схеме
            let transferInfo = hasTransfers ? "С пересадками" : nil
            
            // Получаем дату (используем дату отправления)
            let date = formatDate(departure)
            
            return TripInfo(
                carrier: carrierInfo,
                departureTime: departureTime,
                arrivalTime: arrivalTime,
                duration: durationText,
                date: date,
                hasTransfers: hasTransfers,
                transferInfo: transferInfo
            )
        }
        
        // Сортируем по времени отправления
        trips.sort { $0.departureTime < $1.departureTime }
    }
    
    private func formatTime(_ timeString: String) -> String {
        // Парсим время из формата "2024-01-14 22:30:00" в "22:30"
        let components = timeString.components(separatedBy: " ")
        if components.count >= 2 {
            let timeComponent = components[1]
            let timeParts = timeComponent.components(separatedBy: ":")
            if timeParts.count >= 2 {
                return "\(timeParts[0]):\(timeParts[1])"
            }
        }
        return timeString
    }
    
    private func formatDuration(_ durationSeconds: Int) -> String {
        let hours = durationSeconds / 3600
        let minutes = (durationSeconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours) ч"
        } else {
            return "\(minutes) мин"
        }
    }
    
    private func formatDate(_ timeString: String) -> String {
        // Парсим дату из формата "2024-01-14 22:30:00" в "14 января"
        let components = timeString.components(separatedBy: " ")
        if let dateComponent = components.first {
            let dateParts = dateComponent.components(separatedBy: "-")
            if dateParts.count >= 3 {
                let day = dateParts[2]
                let month = getMonthName(Int(dateParts[1]) ?? 1)
                return "\(day) \(month)"
            }
        }
        return ""
    }
    
    private func getMonthName(_ month: Int) -> String {
        let months = ["", "января", "февраля", "марта", "апреля", "мая", "июня",
                     "июля", "августа", "сентября", "октября", "ноября", "декабря"]
        return months[safe: month] ?? ""
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
