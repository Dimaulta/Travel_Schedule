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

    init(apikey: String) {
        self.apikey = apikey
    }

    func fetchAllCities() async throws -> [DirectoryCity] {
        let url = try makeURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let countries = json?["countries"] as? [[String: Any]] ?? []
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
        let url = try makeURL()
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let countries = json?["countries"] as? [[String: Any]] ?? []
        var result: [DirectoryStation] = []
        let target = normalize(cityTitle)
        for country in countries {
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
                        let stTitle = (station["title"] as? String) ?? (station["short_title"] as? String) ?? ""
                        let codes = station["codes"] as? [String: Any]
                        let yandex = codes?["yandex_code"] as? String
                        if stTitle.isEmpty == false {
                            result.append(DirectoryStation(title: stTitle, yandexCode: yandex))
                        }
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
        return unique.sorted(by: { $0.title < $1.title })
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
}


