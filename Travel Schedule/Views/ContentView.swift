//
//  ContentView.swift
//  Travel Schedule
//
//  Created by Ульта on 29.09.2025. //
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
           
            Task {
                do {
                    let client = Client(
                        serverURL: try Servers.Server1.url(),
                        transport: URLSessionTransport()
                    )
                    let apikey = "50889f83-e54c-4e2e-b9b9-7d5fe468a025" 
                    
                    // 1. Copyright Service
                    let copyrightService = CopyrightService(client: client)
                    let copyright = try await copyrightService.get(apikey: apikey, format: nil)
                    print("Copyright:", copyright)
                    
                    // 2. Nearest Stations Service
                    let nearestStationsService = NearestStationsService(client: client, apikey: apikey)
                    let stations = try await nearestStationsService.getNearestStations(
                        lat: 59.864177, lng: 30.319163, distance: 50
                    )
                    print("Nearest stations:", stations)
                    
                    // 3. Search Service (расписание между станциями)
                    let searchService = SearchService(client: client)
                    let segments = try await searchService.getSegments(
                        apikey: apikey, from: "s9600213", to: "s9600213"
                    )
                    print("Segments:", segments)
                    
                    // 4. Schedule Service (расписание по станции)
                    let scheduleService = ScheduleService(client: client)
                    let schedule = try await scheduleService.getStationSchedule(
                        apikey: apikey, station: "s9600213"
                    )
                    print("Schedule:", schedule)
                    
                    // 5. Thread Service (станции следования)
                    let threadService = ThreadService(client: client)
                    let threadStations = try await threadService.getRouteStations(
                        apikey: apikey, uid: "example_uid"
                    )
                    print("Thread stations:", threadStations)
                    
                    // 6. Nearest City Service
                    let nearestCityService = NearestCityService(client: client)
                    let nearestCity = try await nearestCityService.getNearestCity(
                        apikey: apikey, lat: 59.864177, lng: 30.319163
                    )
                    print("Nearest city:", nearestCity)
                    
                    // 7. Carrier Service
                    let carrierService = CarrierService(client: client)
                    let carrier = try await carrierService.getCarrierInfo(
                        apikey: apikey, code: "example_code"
                    )
                    print("Carrier:", carrier)
                    
                    // 8. All Stations Service
                    let allStationsService = AllStationsService(client: client)
                    let allStations = try await allStationsService.getAllStations(apikey: apikey)
                    print("All stations:", allStations)
                    
                } catch {
                    print("API Error:", error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
