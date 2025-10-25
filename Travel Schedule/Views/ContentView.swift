//
//  ContentView.swift
//  Travel Schedule
//
//  Created by Ульта on 29.09.2025. //.
//

import SwiftUI
import OpenAPIURLSession

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            print("🚀 Запуск всех 8 сервисов...")
            Task {
                do {
                    let client = Client(
                        serverURL: try Servers.Server1.url(),
                        transport: URLSessionTransport()
                    )
                    let apikey = "50889f83-e54c-4e2e-b9b9-7d5fe468a025"
                    
                    // 1. Copyright Service
                    do {
                        let copyrightService = CopyrightService(client: client)
                        let copyright = try await copyrightService.get(apikey: apikey, format: nil)
                        print("✅ Copyright:", copyright)
                    } catch {
                        print("❌ Copyright error:", error)
                    }
                    
                    // 2. Nearest Stations Service
                    do {
                        let nearestStationsService = NearestStationsService(client: client, apikey: apikey)
                        let stations = try await nearestStationsService.getNearestStations(
                            lat: 59.864177, lng: 30.319163, distance: 50
                        )
                        print("✅ Nearest stations:", stations)
                    } catch {
                        print("❌ Nearest stations error:", error)
                    }
                    
                    // 3. Search Service (расписание между станциями)
                    var threadUid: String? = nil
                    var carrierCode: String? = nil
                    
                    do {
                        let searchService = SearchService(client: client)
                        let segments = try await searchService.getSegments(
                            apikey: apikey, 
                            from: "c213", 
                            to: "c2",  // Москва → СПб
                            format: "json",
                            lang: "ru_RU"
                        )
                        print("✅ Segments:", segments)
                        
                        // Извлекаем uid и code из первого сегмента
                        if let firstSegment = segments.segments?.first {
                            threadUid = firstSegment.thread?.uid
                            carrierCode = firstSegment.thread?.carrier?.code?.description
                            print("📋 Найден uid:", threadUid ?? "nil")
                            print("📋 Найден carrier code:", carrierCode ?? "nil")
                        }
                    } catch {
                        print("❌ Segments error:", error)
                    }
                    
                    // 4. Schedule Service (расписание по станции)
                    do {
                        let scheduleService = ScheduleService(client: client)
                        let schedule = try await scheduleService.getStationSchedule(
                            apikey: apikey, 
                            station: "s9602498",  // Балтийский вокзал (из списка станций)
                            lang: "ru_RU",
                            format: "json"
                        )
                        print("✅ Schedule:", schedule)
                    } catch {
                        print("❌ Schedule error:", error)
                    }
                    
                    // 5. Thread Service (станции следования)
                    if let uid = threadUid {
                        do {
                            let threadService = ThreadService(client: client)
                            let threadStations = try await threadService.getRouteStations(
                                apikey: apikey, uid: uid
                            )
                            print("✅ Thread stations:", threadStations)
                        } catch {
                            print("❌ Thread stations error:", error)
                        }
                    } else {
                        print("⏭️ Thread Service пропущен - не найден uid в segments")
                    }
                    
                    // 6. Nearest City Service
                    do {
                        let nearestCityService = NearestCityService(client: client)
                        let nearestCity = try await nearestCityService.getNearestCity(
                            apikey: apikey, lat: 59.864177, lng: 30.319163
                        )
                        print("✅ Nearest city:", nearestCity)
                    } catch {
                        print("❌ Nearest city error:", error)
                    }
                    
                    // 7. Carrier Service
                    if let code = carrierCode {
                        do {
                            let carrierService = CarrierService(client: client)
                            let carrier = try await carrierService.getCarrierInfo(
                                apikey: apikey, code: code
                            )
                            print("✅ Carrier:", carrier)
                        } catch {
                            print("❌ Carrier error:", error)
                        }
                    } else {
                        print("⏭️ Carrier Service пропущен - не найден код перевозчика в segments")
                    }
                    
                    // 8. All Stations Service
                    do {
                        let allStationsService = AllStationsService(client: client)
                        let allStations = try await allStationsService.getAllStations(apikey: apikey)
                        print("✅ All stations:", allStations)
                    } catch {
                        print("❌ All stations error:", error)
                    }
                    
                    // Все сервисы обрабатывают свои ошибки индивидуально
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
