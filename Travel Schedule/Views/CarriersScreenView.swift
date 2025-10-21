//
//  CarriersScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 20.10.2025.
//

import SwiftUI

struct CarriersScreenView: View {
    let fromCity: String
    let fromStation: String
    let toCity: String
    let toStation: String
    let onBack: () -> Void
    
    @StateObject private var viewModel = CarriersViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Навигационная панель
            VStack(spacing: 0) {
                Color("White").frame(height: 12).ignoresSafeArea(edges: .top)
                
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("Black"))
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                .padding(.vertical, 12)
                .padding(.top, 8)
                
                // Заголовок с маршрутом (как в макете)
                HStack(alignment: .center, spacing: 8) {
                    Text("\(fromCity) (\(fromStation))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("Black"))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("GrayUniversal"))
                    Text("\(toCity) (\(toStation))")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("Black"))
                }
                .padding(.bottom, 16)
            }
            .background(Color("White"))
            
            // Основной контент
            if viewModel.isLoading {
                // Индикатор загрузки
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("BlueUniversal")))
                        .scaleEffect(1.5)
                    
                    Text("Загрузка рейсов...")
                        .font(.system(size: 17))
                        .foregroundColor(Color("GrayUniversal"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("White"))
            } else if let errorMessage = viewModel.errorMessage {
                // Сообщение об ошибке
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(Color("RedUniversal"))
                    
                    Text("Ошибка")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Black"))
                    
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(Color("GrayUniversal"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button("Попробовать снова") {
                        Task {
                            await loadTrips()
                        }
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("BlueUniversal"))
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("White"))
            } else if viewModel.trips.isEmpty {
                // Пустой список
                VStack(spacing: 16) {
                    Image(systemName: "train")
                        .font(.system(size: 48))
                        .foregroundColor(Color("GrayUniversal"))
                    
                    Text("Рейсы не найдены")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Black"))
                    
                    Text("Попробуйте изменить дату или маршрут")
                        .font(.system(size: 16))
                        .foregroundColor(Color("GrayUniversal"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color("White"))
            } else {
                // Список рейсов с кнопкой поверх
                ZStack(alignment: .bottom) {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.trips) { trip in
                                CarrierCardView(trip: trip)
                                    .onTapGesture {
                                        // TODO: Переход к детальной информации о рейсе
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100) // Отступ для кнопки внизу
                    }
                    
                    // Кнопка "Уточнить время" поверх скролла
                    VStack {
                        Button(action: {
                            // TODO: Открыть экран уточнения времени
                        }) {
                            Text("Уточнить время")
                                .font(.system(size: 17, weight: .bold))
                                .foregroundColor(Color("WhiteUniversal"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color("BlueUniversal"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    }
                }
            }
        }
      //  .background(Color("White"))
        .onAppear {
            Task {
                await loadTrips()
            }
        }
    }
    
    private func loadTrips() async {
        do {
            // Создаем экземпляр DirectoryService
            let directoryService = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            
            // Получаем станции для городов
            let fromStations = try await directoryService.fetchStations(inCityTitle: fromCity)
            let toStations = try await directoryService.fetchStations(inCityTitle: toCity)
            
            // Находим коды станций по названиям
            let fromCode = fromStations.first { $0.title == fromStation }?.yandexCode
            let toCode = toStations.first { $0.title == toStation }?.yandexCode
            
            guard let fromCode = fromCode, let toCode = toCode else {
                await MainActor.run {
                    viewModel.errorMessage = "Не удалось найти коды станций"
                }
                return
            }
            
            await viewModel.loadTrips(
                from: fromCode,
                to: toCode,
                fromStation: fromStation,
                toStation: toStation
            )
        } catch {
            await MainActor.run {
                viewModel.errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    CarriersScreenView(
        fromCity: "Москва",
        fromStation: "Ярославский вокзал",
        toCity: "Санкт-Петербург",
        toStation: "Балтийский вокзал",
        onBack: {}
    )
}
