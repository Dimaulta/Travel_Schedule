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
            Image(systemName: "globe") // Пример содержимого View
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .onAppear {
            // Вызываем нашу тестовую функцию при появлении View
          //  testFetchStations()
        }
    }
}

#Preview {
    ContentView()
}

// Функция для тестового вызова API
//func testFetchStations() {
//    // Создаём Task для выполнения асинхронного кода
//    Task {
//        do {
//            // 1. Создаём экземпляр сгенерированного клиента
//            let client = Client(
//                // Используем URL сервера, также сгенерированный из openapi.yaml (если он там определён)
//                serverURL: try Servers.Server1.url(),
//                // Указываем, какой транспорт использовать для отправки запросов
//                transport: URLSessionTransport()
//            )
//            
//            // 2. Создаём экземпляр нашего сервиса, передавая ему клиент и API-ключ
//            let service = NearestStationsService(
//                client: client,
//                apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025" // !!! ЗАМЕНИТЕ НА СВОЙ РЕАЛЬНЫЙ КЛЮЧ !!!
//            )
//            
//            // 3. Вызываем метод сервиса
//            print("Fetching stations...")
//            let stations = try await service.getNearestStations(
//                lat: 59.864177, // Пример координат
//                lng: 30.319163, // Пример координат
//                distance: 50    // Пример дистанции
//            )
//            
//            // 4. Если всё успешно, печатаем результат в консоль
//            print("Successfully fetched stations: \(stations)")
//        } catch {
//            // 5. Если произошла ошибка на любом из этапов (создание клиента, вызов сервиса, обработка ответа),
//            //    она будет поймана здесь, и мы выведем её в консоль
//            print("Error fetching stations: \(error)")
//            // В реальном приложении здесь должна быть логика обработки ошибок (показ алерта и т. д.)
//        }
//    }
//}
