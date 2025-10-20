//
//  DirectoryService.swift
//  Travel Schedule
//
//  Created by Ульта on 19.10.2025.
//

import Foundation

struct DirectoryCity: Hashable {
    let title: String
}

struct DirectoryStation: Hashable {
    let title: String
    let yandexCode: String?
}

final class DirectoryService {
    private let apikey: String
    // Общий кеш для всего списка станций (для всех инстансов сервиса)
    // Храним уже извлечённый массив стран из JSON, чтобы не дергать сеть повторно
    private static var cachedCountries: [[String: Any]]?
    private static var loadingTask: Task<[[String: Any]], Error>?

    init(apikey: String) {
        self.apikey = apikey
    }

    func fetchAllCities() async throws -> [DirectoryCity] {
        let countries = try await loadCountries()
        var set = Set<String>()
        for country in countries {
            let regions = country["regions"] as? [[String: Any]] ?? []
            for region in regions {
                let settlements = region["settlements"] as? [[String: Any]] ?? []
                for settlement in settlements {
                    if let title = settlement["title"] as? String, title.isEmpty == false {
                        set.insert(title)
                    }
                }
            }
        }
        return set.sorted().map { DirectoryCity(title: $0) }
    }

    func fetchStations(inCityTitle cityTitle: String) async throws -> [DirectoryStation] {
        // Защита от пустой строки - иначе загрузятся ВСЕ станции
        let trimmed = cityTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return []
        }
        
        let countries = try await loadCountries()
        var result: [DirectoryStation] = []
        let target = normalize(trimmed)
        for country in countries {
            let countryTitle = (country["title"] as? String) ?? ""
            // Фильтруем только по России для всех городов
            guard countryTitle.contains("Россия") || countryTitle.contains("Russia") else { continue }
            
            let regions = country["regions"] as? [[String: Any]] ?? []
            for region in regions {
                let settlements = region["settlements"] as? [[String: Any]] ?? []
                for settlement in settlements {
                    let title = (settlement["title"] as? String) ?? ""
                    let popular = (settlement["popular_title"] as? String) ?? ""
                    let short = (settlement["short_title"] as? String) ?? ""
                    let matches = [title, popular, short].map { normalize($0) }.contains(target)
                    guard matches else { continue }
                    
                    let stations = settlement["stations"] as? [[String: Any]] ?? []
                    for station in stations {
                        // Берем только ж/д станции с валидным кодом Яндекса
                        let transportType = (station["transport_type"] as? String) ?? ""
                        guard transportType == "train" else { continue }

                        let rawTitle = (station["title"] as? String) ?? (station["short_title"] as? String) ?? ""
                        let codes = station["codes"] as? [String: Any]
                        let yandex = codes?["yandex_code"] as? String
                        guard let code = yandex, code.isEmpty == false else { continue }

                        // Мы уже находимся внутри settlement выбранного города,
                        // поэтому дополнительно фильтровать по городу не нужно –
                        // просто показываем чистое имя вокзала без города
                        let onlyStationName = extractStationName(fromFullTitle: rawTitle, cityTitle: cityTitle)
                        guard onlyStationName.isEmpty == false else { continue }
                        
                        // Для всех городов России показываем только станции с кириллическими названиями
                        let hasCyrillic = onlyStationName.unicodeScalars.contains { scalar in
                            (0x0400...0x04FF).contains(scalar.value) // Кириллический диапазон
                        }
                        guard hasCyrillic else { continue }
                        
                        result.append(DirectoryStation(title: onlyStationName, yandexCode: code))
                    }
                }
            }
        }
        // Deduplicate by title
        var seen = Set<String>()
        var unique: [DirectoryStation] = []
        for s in result {
            if seen.insert(s.title).inserted { unique.append(s) }
        }
        
        // Сортируем: сначала станции, начинающиеся с букв, потом с цифр
        return unique.sorted { station1, station2 in
            let title1 = station1.title
            let title2 = station2.title
            
            // Проверяем, начинается ли с буквы или цифры
            let isLetter1 = title1.first?.isLetter ?? false
            let isLetter2 = title2.first?.isLetter ?? false
            
            if isLetter1 && !isLetter2 {
                return true  // станция1 (буква) идет перед станцией2 (цифра)
            } else if !isLetter1 && isLetter2 {
                return false // станция2 (буква) идет перед станцией1 (цифра)
            } else {
                // Обе начинаются с букв или обе с цифр - сортируем по алфавиту
                return title1 < title2
            }
        }
    }

    // MARK: - Кеширующий загрузчик
    private func loadCountries() async throws -> [[String: Any]] {
        if let cached = Self.cachedCountries { return cached }
        if let task = Self.loadingTask { return try await task.value }
        let task = Task { () throws -> [[String: Any]] in
            let url = try makeURL()
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let countries = json?["countries"] as? [[String: Any]] ?? []
            Self.cachedCountries = countries
            Self.loadingTask = nil
            return countries
        }
        Self.loadingTask = task
        return try await task.value
    }

    private func normalize(_ value: String) -> String {
        value
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .lowercased()
    }

    private func makeURL() throws -> URL {
        var components = URLComponents(string: "https://api.rasp.yandex.net/v3.0/stations_list/")!
        components.queryItems = [
            URLQueryItem(name: "apikey", value: apikey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lang", value: "ru_RU")
        ]
        guard let url = components.url else { throw URLError(.badURL) }
        return url
    }

    // MARK: - Title helpers
    private func belongsToCity(_ stationTitle: String, cityTitle: String) -> Bool {
        let stationCity = extractCity(fromStationTitle: stationTitle)
        return normalize(stationCity) == normalize(cityTitle)
    }

    private func extractCity(fromStationTitle title: String) -> String {
        // Примеры входа:
        // "Москва (Казанский вокзал)", "Брюссель, Северный вокзал", "Курган (пригородный вокзал)"
        if let commaIdx = title.firstIndex(of: ",") {
            return String(title[..<commaIdx])
        }
        if let parenIdx = title.firstIndex(of: "(") {
            return String(title[..<parenIdx]).trimmingCharacters(in: .whitespaces)
        }
        return title
    }

    private func extractStationName(fromFullTitle title: String, cityTitle: String) -> String {
        // Хотим вернуть только часть названия вокзала без города:
        // "Москва (Казанский вокзал)" -> "Казанский вокзал"
        // "Москва, Белорусский вокзал" -> "Белорусский вокзал"
        if let commaIdx = title.firstIndex(of: ",") {
            let after = title.index(after: commaIdx)
            return String(title[after...]).trimmingCharacters(in: .whitespaces)
        }
        if let open = title.firstIndex(of: "("), let close = title.firstIndex(of: ")"), open < close {
            let inside = title.index(after: open)..<close
            return String(title[inside]).trimmingCharacters(in: .whitespaces)
        }
        // Если строка начинается с названия города — пробуем отрезать его
        let normTitle = normalize(title)
        let normCity = normalize(cityTitle)
        if normTitle.hasPrefix(normCity) {
            let trimmed = title.dropFirst(cityTitle.count).trimmingCharacters(in: .whitespaces)
            return trimmed
        }
        // Ничего не нашли — возвращаем исходное (лучше показать, чем потерять)
        return title
    }
}


