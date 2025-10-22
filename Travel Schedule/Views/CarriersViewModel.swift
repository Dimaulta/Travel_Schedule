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
    let sortDate: Date // Для правильной сортировки
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
    private var currentFilters: FilterOptions?
    
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
            // Определяем параметр transfers на основе фильтров
            let transfers: Bool?
            if let filters = currentFilters, let showTransfers = filters.showTransfers {
                transfers = (showTransfers == .yes)
            } else {
                transfers = nil
            }
            
            let segments = try await searchService.getSegments(
                apikey: apikey,
                from: from,
                to: to,
                format: "json",
                lang: "ru_RU",
                transport_types: "train", // Только поезда
                limit: 1000, // Запрашиваем максимум результатов
                transfers: transfers // Передаем параметр пересадок
            )
            
            await processSegments(segments)
        } catch {
            errorMessage = "Ошибка загрузки рейсов: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func setFilters(_ filters: FilterOptions?) {
        currentFilters = filters
    }
    
    private func processSegments(_ segments: Segments) async {
        guard let segmentsArray = segments.segments else {
            errorMessage = "Рейсы не найдены"
            return
        }
        
        // Обрабатываем обычные segments
        var allTrips: [TripInfo] = []
        
        // Обрабатываем обычные segments
        let regularTrips = segmentsArray.compactMap { segment -> TripInfo? in
            return createTripInfo(from: segment, hasTransfers: false)
        }
        allTrips.append(contentsOf: regularTrips)
        
        // Обрабатываем interval_segments если они есть (содержат информацию о пересадках)
        if let intervalSegments = segments.interval_segments {
            let intervalTrips = intervalSegments.compactMap { intervalSegment -> TripInfo? in
                // Создаем TripInfo из interval_segment
                return createTripInfoFromInterval(intervalSegment)
            }
            allTrips.append(contentsOf: intervalTrips)
        }
        
        trips = allTrips
        
        // Применяем фильтры
        if let filters = currentFilters {
            trips = applyFilters(trips, filters: filters)
        }
        
        // Сортируем по дате и времени отправления (без удаления дублей)
        trips = trips.sorted { trip1, trip2 in
            trip1.sortDate < trip2.sortDate
        }
    }
    
    private func formatTime(_ timeString: String) -> String {
        // Поддержка форматов: "YYYY-MM-DD HH:mm:ss" и "HH:mm:ss" → "HH:mm"
        let parts = timeString.contains(" ") ? timeString.components(separatedBy: " ") : ["", timeString]
        let timeComponent = parts.last ?? timeString
        let timeParts = timeComponent.components(separatedBy: ":")
        guard timeParts.count >= 2 else { return timeComponent }
        return "\(timeParts[0]):\(timeParts[1])"
    }
    
    private func formatDuration(_ durationSeconds: Int) -> String {
        let hours = durationSeconds / 3600
        let word = pluralizeHours(hours)
        return "\(hours) \(word)"
    }

    private func pluralizeHours(_ value: Int) -> String {
        let v = value % 100
        if v >= 11 && v <= 14 { return "часов" }
        switch v % 10 {
        case 1: return "час"
        case 2,3,4: return "часа"
        default: return "часов"
        }
    }
    
    private func formatDate(_ timeString: String) -> String {
        // Извлекаем дату из строки формата "YYYY-MM-DD HH:mm:ss" или "YYYY-MM-DDTHH:mm:ss"
        let dateComponent: String
        
        // Проверяем формат с пробелом
        if timeString.contains(" ") {
            dateComponent = timeString.components(separatedBy: " ").first ?? ""
        } 
        // Проверяем формат ISO 8601 с T
        else if timeString.contains("T") {
            dateComponent = timeString.components(separatedBy: "T").first ?? ""
        } 
        else {
            // Если формат неизвестен, используем текущую дату
            let now = Date()
            let calendar = Calendar.current
            let day = calendar.component(.day, from: now)
            let month = calendar.component(.month, from: now)
            let monthName = getMonthName(month)
            return "\(day) \(monthName)"
        }
        
        // Парсим дату в формате YYYY-MM-DD
        let dateParts = dateComponent.components(separatedBy: "-")
        guard dateParts.count == 3,
              let day = Int(dateParts[2]),
              let month = Int(dateParts[1]) else {
            // Если не удалось распарсить, используем текущую дату
            let now = Date()
            let calendar = Calendar.current
            let dayVal = calendar.component(.day, from: now)
            let monthVal = calendar.component(.month, from: now)
            let monthName = getMonthName(monthVal)
            return "\(dayVal) \(monthName)"
        }
        
        let monthName = getMonthName(month)
        return "\(day) \(monthName)"
    }
    
    private func getMonthName(_ month: Int) -> String {
        let months = ["", "января", "февраля", "марта", "апреля", "мая", "июня",
                     "июля", "августа", "сентября", "октября", "ноября", "декабря"]
        return months[safe: month] ?? ""
    }
    
    private func parseDate(_ timeString: String) -> Date {
        // Парсим дату из строки формата "YYYY-MM-DD HH:mm:ss" или "YYYY-MM-DDTHH:mm:ss"
        let formatter = ISO8601DateFormatter()
        
        // Пробуем стандартный ISO 8601 формат
        if let date = formatter.date(from: timeString) {
            return date
        }
        
        // Пробуем формат с пробелом вместо T
        let modifiedString = timeString.replacingOccurrences(of: " ", with: "T")
        if let date = formatter.date(from: modifiedString) {
            return date
        }
        
        // Пробуем формат без секунд
        formatter.formatOptions = [.withInternetDateTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        if let date = formatter.date(from: timeString) {
            return date
        }
        
        // Если не удалось распарсить, возвращаем текущую дату
        return Date()
    }
    
    private func applyFilters(_ trips: [TripInfo], filters: FilterOptions) -> [TripInfo] {
        var filteredTrips = trips
        
        // Фильтрация по времени отправления
        if !filters.timeSlots.isEmpty {
            filteredTrips = filteredTrips.filter { trip in
                let hour = getHourFromTime(trip.departureTime)
                return filters.timeSlots.contains { timeSlot in
                    switch timeSlot {
                    case .morning: return hour >= 6 && hour < 12
                    case .day: return hour >= 12 && hour < 18
                    case .evening: return hour >= 18 && hour < 24
                    case .night: return hour >= 0 && hour < 6
                    }
                }
            }
        }
        
        // Фильтрация по пересадкам теперь работает через API параметр transfers
        
        return filteredTrips
    }
    
    private func getHourFromTime(_ timeString: String) -> Int {
        let components = timeString.components(separatedBy: ":")
        guard components.count >= 2,
              let hour = Int(components[0]) else {
            return 0
        }
        return hour
    }
    
    private func createTripInfo(from segment: Components.Schemas.Segment, hasTransfers: Bool) -> TripInfo? {
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
        
        // Получаем информацию о перевозчике (без вторых названий через "/")
        let carrierTitle = (carrier.title ?? "Неизвестный перевозчик").components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? (carrier.title ?? "Неизвестный перевозчик")
        
        let carrierInfo = CarrierInfo(
            title: carrierTitle,
            logo: carrier.logo,
            code: carrier.code
        )
        
        // Получаем дату из реальных данных API
        let date = formatDate(departure)
        let sortDate = parseDate(departure)
        
        // Определяем информацию о пересадках
        let transferInfo = hasTransfers ? "С пересадками" : nil
        
        return TripInfo(
            carrier: carrierInfo,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            duration: durationText,
            date: date,
            hasTransfers: hasTransfers,
            transferInfo: transferInfo,
            sortDate: sortDate
        )
    }
    
    private func createTripInfoFromInterval(_ intervalSegment: Components.Schemas.Segments.interval_segmentsPayloadPayload) -> TripInfo? {
        guard let departure = intervalSegment.from?.title, // Используем from как departure
              let arrival = intervalSegment.to?.title, // Используем to как arrival
              let duration = intervalSegment.duration,
              let thread = intervalSegment.thread,
              let carrier = thread.carrier else {
            return nil
        }
        
        // Форматируем время (для interval_segments время может быть в другом формате)
        let departureTime = formatTime(departure)
        let arrivalTime = formatTime(arrival)
        let durationText = formatDuration(duration)
        
        // Получаем информацию о перевозчике
        let carrierTitle = (carrier.title ?? "Неизвестный перевозчик").components(separatedBy: "/").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? (carrier.title ?? "Неизвестный перевозчик")
        
        let carrierInfo = CarrierInfo(
            title: carrierTitle,
            logo: carrier.logo,
            code: carrier.code
        )
        
        // Получаем информацию о пересадках из interval_segment
        let hasTransfers = intervalSegment.has_transfers ?? false
        let transferInfo = hasTransfers ? "С пересадками" : nil
        
        // Для interval_segments используем текущую дату
        let now = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: now)
        let month = calendar.component(.month, from: now)
        let monthName = getMonthName(month)
        let date = "\(day) \(monthName)"
        
        return TripInfo(
            carrier: carrierInfo,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            duration: durationText,
            date: date,
            hasTransfers: hasTransfers,
            transferInfo: transferInfo,
            sortDate: now
        )
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
