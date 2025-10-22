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
    @State private var showFilter = false
    @State private var currentFilters: FilterOptions?
    @State private var showCarrierInfo = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternet = false
    
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
                // Экран "Вариантов нет" (без дублирования верхней панели и маршрута)
                ZStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        Text("Вариантов нет")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color("Black"))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color("White"))

                    // Кнопка "Уточнить время" внизу
                    VStack {
                        Button(action: { showFilter = true }) {
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
            } else {
                // Список рейсов с кнопкой поверх
                ZStack(alignment: .bottom) {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.trips) { trip in
                                CarrierCardView(trip: trip)
                                    .onTapGesture {
                                        showCarrierInfo = true
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
                            showFilter = true
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
        .navigationDestination(isPresented: $showFilter) {
            FilterScreenView(
                onBack: {
                    showFilter = false
                },
                onApply: { filters in
                    currentFilters = filters
                    viewModel.setFilters(filters)
                    showFilter = false
                    // Перезагружаем результаты с фильтрами
                    Task {
                        await loadTrips()
                    }
                }
            )
        }
        .navigationDestination(isPresented: $showCarrierInfo) {
            CarrierInfoView(onBack: {
                showCarrierInfo = false
            })
        }
        .onAppear {
            // Проверяем статус сети при появлении экрана
            if !networkMonitor.isConnected {
                showNoInternet = true
            } else {
                Task {
                    await loadTrips()
                }
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if !isConnected {
                showNoInternet = true
            } else if isConnected && showNoInternet {
                // Автоматически скрываем экран "Нет интернета" при восстановлении соединения
                showNoInternet = false
            }
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView()
        }
    }
    
    private func loadTrips() async {
        // Проверяем статус сети перед загрузкой
        if !networkMonitor.isConnected {
            await MainActor.run {
                showNoInternet = true
            }
            return
        }
        
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
                // Определяем тип ошибки и показываем соответствующий экран
                if error.localizedDescription.contains("network") || 
                   error.localizedDescription.contains("internet") ||
                   error.localizedDescription.contains("offline") {
                    showNoInternet = true
                } else {
                    // Показываем ошибку сервера (можно добавить отдельный экран)
                    viewModel.errorMessage = "Ошибка сервера"
                }
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
