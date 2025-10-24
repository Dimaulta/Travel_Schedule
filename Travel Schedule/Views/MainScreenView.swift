//
//  MainScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI
import OpenAPIURLSession

struct MainScreenView: View {
    @ObservedObject var sessionManager: SessionManager
    let onServerError: () -> Void
    let onNoInternet: () -> Void
    let onTabSelected: ((Int) -> Void)?
    
    @State private var showCityPicker = false
    @State private var pickerTarget: PickerTarget? = nil
    @State private var showCarriers = false
    @State private var didPrefetchDirectory = false
    
    var body: some View {
        ZStack {
            // Основной фон
            Color("White")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Сторис карточки
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<4) { index in
                                StoryCardView(isActive: index < 2)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)

                    // Поисковая панель (слитная, выше)
                    ZStack(alignment: .trailing) {
                        // Синий фон поисковой панели с отступами 16 слева/справа
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("BlueUniversal"))
                            .frame(height: 135)

                        // Белый блок не на всю ширину (справа зазор под кнопку)
                        HStack(spacing: 0) {
                            // Белый блок тянется по ширине, оставляя место под кнопку справа
                            VStack(spacing: 32) {
                                HStack {
                                    Text(displayText(city: sessionManager.fromCity, station: sessionManager.fromStation, placeholder: "Откуда"))
                                        .font(.system(size: 17))
                                        .foregroundColor(sessionManager.fromCity == nil ? Color("GrayUniversal") : Color("BlackUniversal"))
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    pickerTarget = .from
                                    showCityPicker = true
                                }
                                HStack {
                                    Text(displayText(city: sessionManager.toCity, station: sessionManager.toStation, placeholder: "Куда"))
                                        .font(.system(size: 17))
                                        .foregroundColor(sessionManager.toCity == nil ? Color("GrayUniversal") : Color("BlackUniversal"))
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    pickerTarget = .to
                                    showCityPicker = true
                                }
                            }
                            .padding(.leading, 16)
                            .padding(.vertical, 16) // внутренние отступы сверху/снизу по 16
                            .frame(height: 103)
                            .background(Color("WhiteUniversal"))
                            .cornerRadius(20)
                          
                            // Зазор до правого края: 16 (между полем и кнопкой) + 44 (кнопка) + 16 (правый край) = 76
                            Spacer()
                                .frame(width: 60)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)

                        // Кнопка переключения (картинка из ассетов)
                        Button(action: {
                            swap(&sessionManager.fromCity, &sessionManager.toCity)
                            swap(&sessionManager.fromStation, &sessionManager.toStation)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color("WhiteUniversal"))
                                    .frame(width: 44, height: 44)
                                Image("Change")
                                    .renderingMode(.original)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                            }
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 48)

                    // Кнопка "Найти" (показывается, когда оба поля заполнены)
                    if (sessionManager.fromCity?.isEmpty == false) && (sessionManager.toCity?.isEmpty == false) {
                        SearchPrimaryButton(title: "Найти") {
                            showCarriers = true
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.2), value: sessionManager.fromCity)
                        .animation(.easeOut(duration: 0.2), value: sessionManager.toCity)
                        .padding(.top, 12)
                    }

                    Spacer()
            }
        }
        .fullScreenCover(isPresented: $showCityPicker) {
            CityPickerView(
                viewModel: CityPickerViewModel(),
                onSelect: { selection in
                    if pickerTarget == .from {
                        sessionManager.fromCity = selection.city
                        sessionManager.fromStation = selection.station
                    } else {
                        sessionManager.toCity = selection.city
                        sessionManager.toStation = selection.station
                    }
                    showCityPicker = false
                },
                onCancel: {
                    showCityPicker = false
                },
                onTabSelected: onTabSelected
            )
        }
        // Предзагрузка полного справочника станций один раз при первом появлении
        .task {
            guard didPrefetchDirectory == false else { return }
            didPrefetchDirectory = true
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            do {
                _ = try await directory.fetchAllCities()
            } catch {
                // Определяем тип ошибки и показываем соответствующий экран
                if error.localizedDescription.contains("network") || 
                   error.localizedDescription.contains("internet") ||
                   error.localizedDescription.contains("offline") {
                    onNoInternet()
                } else {
                    onServerError()
                }
            }
        }
        .navigationDestination(isPresented: $showCarriers) {
            if let fromCity = sessionManager.fromCity,
               let fromStation = sessionManager.fromStation,
               let toCity = sessionManager.toCity,
               let toStation = sessionManager.toStation {
                CarriersScreenView(
                    fromCity: fromCity,
                    fromStation: fromStation,
                    toCity: toCity,
                    toStation: toStation,
                    onBack: {
                        showCarriers = false
                    },
                    onServerError: onServerError,
                    onNoInternet: onNoInternet
                )
            }
        }
    }
}

struct StoryCardView: View {
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Заглушка для изображения
            Rectangle()
                .fill(Color("GrayUniversal").opacity(0.3))
                .frame(width: 92, height: 105)
                .cornerRadius(16, corners: [.topLeft, .topRight])
            
            Text("Text Text Text Text Text Text Text Text Text")
                .font(.system(size: 12))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
        }
        .frame(width: 92, height: 140)
        .background(Color("GrayUniversal").opacity(0.5))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isActive ? Color("BlueUniversal") : Color.clear,
                    lineWidth: 2
                )
        )
        .opacity(isActive ? 1.0 : 0.5)
    }
}


// Расширение для скругления отдельных углов
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
// Цель выбора города
private enum PickerTarget { case from, to }


#Preview {
    MainScreenView(
        sessionManager: SessionManager(),
        onServerError: {},
        onNoInternet: {},
        onTabSelected: nil
    )
}


// MARK: - City Picker (MVVM, lightweight, no project file edits)

struct City: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

final class CityPickerViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var allCities: [City] = []
    private let defaultCities: [City] = [
        City(name: "Москва"),
        City(name: "Санкт Петербург"),
        City(name: "Сочи"),
        City(name: "Горный воздух"),
        City(name: "Краснодар"),
        City(name: "Казань"),
        City(name: "Омск")
    ]
    private var onServerError: (() -> Void)?

    func setErrorCallback(onServerError: @escaping () -> Void) {
        self.onServerError = onServerError
    }

    func loadCities() async {
        do {
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            let cities = try await directory.fetchAllCities()
            let mapped = cities.map { City(name: $0.title) }
            await MainActor.run { self.allCities = mapped.isEmpty ? self.defaultCities : mapped }
        } catch {
            // Определяем тип ошибки и вызываем соответствующий callback
            if error.localizedDescription.contains("network") || 
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                // Ошибка сети - показываем fallback данные
                await MainActor.run { self.allCities = self.defaultCities }
            } else {
                // Ошибка сервера - вызываем callback
                onServerError?()
            }
        }
    }
    
    // Временный метод для тестирования ошибки сервера
    func simulateServerError() {
        onServerError?()
    }

    var filtered: [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        // Пустой поиск: показываем только дефолтные города
        guard trimmed.isEmpty == false else { return defaultCities }
        // Поиск: по всем городам (реальные + дефолтные)
        let allNames = (allCities + defaultCities).map { $0.name }
        let uniqueSorted = Array(Set(allNames)).sorted()
        return uniqueSorted
            .filter { $0.lowercased().contains(trimmed.lowercased()) }
            .map { City(name: $0) }
    }
}

struct CityStationSelection {
    let city: String
    let station: String?
}

struct CityPickerView: View {
    @ObservedObject var viewModel: CityPickerViewModel
    let onSelect: (CityStationSelection) -> Void
    let onCancel: () -> Void
    let onTabSelected: ((Int) -> Void)?
    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCity: City? = nil
    // Убираем локальный показ "Нет интернета" — централизованно управляет MainTabView
    @State private var showServerError = false
    @StateObject private var stationsViewModel = StationsPickerViewModel() // Создаем один раз

    var body: some View {
        VStack(spacing: 0) {
            // Фон под вырез/статусбар
            Color("White")
                .frame(height: 12)
                .ignoresSafeArea(edges: .top)

            // Навбар
            ZStack {
                Text("Выбор города")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("Black"))
                    .multilineTextAlignment(.center)
                HStack {
                    Button(action: { onCancel() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("Black"))
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.top, 8)

            // Поисковая строка
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("GrayUniversal"))
                TextField("Введите запрос", text: $viewModel.query)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .foregroundColor(Color("Black"))
                    .focused($searchFocused)
                if searchFocused {
                    Button(action: { viewModel.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("GrayUniversal"))
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color("SearchCity"))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            // Список / заглушка
            if viewModel.filtered.isEmpty && viewModel.query.isEmpty == false {
                VStack { // центрируем фразу и отступаем от серчбара
                    Text("Город не найден")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("Black"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 180)
                    
                    // TODO: Убрать кнопку тестирования после завершения разработки
                    // Временная кнопка для тестирования ошибки сервера
                    Button("Тест: Ошибка сервера") {
                        viewModel.simulateServerError()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("BlueUniversal"))
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.filtered) { city in
                            Button(action: {
                                selectedCity = city
                            }) {
                                HStack {
                                    Text(city.name)
                                        .foregroundColor(Color("Black"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color("Black"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(Color("White"))
                        }
                    }
                }
                .background(Color("White"))
            }
        }
        .background(Color("White"))
        .onAppear {
            // Настраиваем callback для ошибки сервера
            viewModel.setErrorCallback {
                showServerError = true
            }
            
            DispatchQueue.main.async { UIResponder.currentFirstResponderBecomesFirst(text: viewModel) }
            Task { await viewModel.loadCities() }
        }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: onTabSelected ?? { _ in })
        }
        .fullScreenCover(item: $selectedCity) { city in
            StationsPickerView(
                cityTitle: city.name,
                viewModel: stationsViewModel, // Переиспользуемый viewModel
                onSelect: { station in
                    onSelect(CityStationSelection(city: city.name, station: station.title))
                    selectedCity = nil
                },
                onCancel: { selectedCity = nil },
                onTabSelected: onTabSelected
            )
        }
    }
}

// Helper to focus first responder on appear (lightweight placeholder)
private extension UIResponder {
    static func currentFirstResponderBecomesFirst(text: CityPickerViewModel) { /* no-op; native focus оставим пользователю */ }
}

// MARK: - Primary Button used under the blue container
struct SearchPrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("WhiteUniversal"))
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 8)
            .frame(width: 150)
            .background(Color("BlueUniversal"))
            .cornerRadius(16)
        }
    }
}

// MARK: - Stations Picker

struct Station: Identifiable, Equatable {
    let id = UUID()
    let code: String?
    let title: String
}

final class StationsPickerViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var allStations: [Station] = []
    @Published var isLoading: Bool = false
    private var onServerError: (() -> Void)?
    private var currentCityTitle: String? = nil

    func setErrorCallback(onServerError: @escaping () -> Void) {
        self.onServerError = onServerError
    }

    func load(forCityTitle cityTitle: String) async {
        print("🚀 StationsPickerViewModel: Начинаем загрузку для города: \(cityTitle)")
        
        // Проверяем, не загружаем ли мы уже этот город
        if currentCityTitle == cityTitle && !allStations.isEmpty {
            print("✅ StationsPickerViewModel: Данные уже загружены для \(cityTitle)")
            return
        }
        
        // Защита от повторной загрузки
        if isLoading {
            print("⚠️ StationsPickerViewModel: Загрузка уже идет, пропускаем")
            return
        }
        
        // Защита от повторной загрузки того же города
        if currentCityTitle == cityTitle {
            print("⚠️ StationsPickerViewModel: Уже загружаем этот город, пропускаем")
            return
        }
        
        await MainActor.run { 
            print("📱 StationsPickerViewModel: Устанавливаем isLoading = true")
            self.isLoading = true
            self.currentCityTitle = cityTitle
            // Не очищаем allStations сразу, чтобы избежать мерцания
            self.query = "" // Очищаем поисковый запрос
        }
        defer { 
            print("🏁 StationsPickerViewModel: Завершаем загрузку, isLoading = false")
            Task { @MainActor in
                self.isLoading = false 
            }
        }
        do {
            print("🌐 StationsPickerViewModel: Делаем API запрос для \(cityTitle)")
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            let stations = try await directory.fetchStations(inCityTitle: cityTitle)
            let mapped = stations.map { Station(code: $0.yandexCode, title: $0.title) }
            print("📊 StationsPickerViewModel: Получили \(mapped.count) станций")
        await MainActor.run { 
            self.allStations = mapped 
            print("💾 StationsPickerViewModel: Сохранили \(mapped.count) станций в allStations")
            print("🔍 StationsPickerViewModel: allStations после сохранения: \(self.allStations.count)")
        }
        } catch {
            // Определяем тип ошибки и вызываем соответствующий callback
            if error.localizedDescription.contains("network") || 
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                // Ошибка сети - показываем пустой список
                await MainActor.run { self.allStations = [] }
            } else {
                // Ошибка сервера - вызываем callback
                onServerError?()
            }
        }
    }

    var filtered: [Station] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        print("🔍 StationsPickerViewModel: filtered вызван, allStations.count = \(allStations.count), query = '\(query)'")
        guard trimmed.isEmpty == false else { 
            print("🔍 StationsPickerViewModel: возвращаем allStations (\(allStations.count) элементов)")
            return allStations 
        }
        let result = allStations.filter { $0.title.lowercased().contains(trimmed.lowercased()) }
        print("🔍 StationsPickerViewModel: возвращаем отфильтрованный результат (\(result.count) элементов)")
        return result
    }
}

struct StationsPickerView: View {
    let cityTitle: String
    @ObservedObject var viewModel: StationsPickerViewModel
    let onSelect: (Station) -> Void
    let onCancel: () -> Void
    let onTabSelected: ((Int) -> Void)?
    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternet = false
    @State private var showServerError = false
    
    init(cityTitle: String, viewModel: StationsPickerViewModel, onSelect: @escaping (Station) -> Void, onCancel: @escaping () -> Void, onTabSelected: ((Int) -> Void)?) {
        self.cityTitle = cityTitle
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.onCancel = onCancel
        self.onTabSelected = onTabSelected
        print("🔍 StationsPickerView: Инициализация для города: \(cityTitle)")
    }

    var body: some View {
        VStack(spacing: 0) {
            Color("White").frame(height: 12).ignoresSafeArea(edges: .top)
            ZStack {
                Text("Выбор станции")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("Black"))
                HStack {
                    Button(action: { onCancel() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("Black"))
                    }
                    .padding(.leading, 16)
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.top, 8)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color("GrayUniversal"))
                TextField("Введите запрос", text: $viewModel.query)
                    .textInputAutocapitalization(.words)
                    .disableAutocorrection(true)
                    .foregroundColor(Color("Black"))
                    .focused($searchFocused)
                if searchFocused {
                    Button(action: { viewModel.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color("GrayUniversal"))
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color("SearchCity"))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("BlueUniversal")))
                        .scaleEffect(1.4)
                        .padding(.top, 120)
                    Text("Загрузка станций...")
                        .foregroundColor(Color("GrayUniversal"))
                        .padding(.top, 8)
                    Spacer()
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Добавляем логирование для отладки
                        let _ = print("🔍 UI: allStations.count = \(viewModel.allStations.count)")
                        let _ = print("🔍 UI: filtered.count = \(viewModel.filtered.count)")
                        let _ = print("🔍 UI: isLoading = \(viewModel.isLoading)")
                        
                        ForEach(viewModel.filtered) { station in
                            Button(action: { onSelect(station) }) {
                                HStack {
                                    Text(station.title)
                                        .foregroundColor(Color("Black"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color("Black"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(Color("White"))
                        }
                    }
                }
                .background(Color("White"))
            }
        }
        .background(Color("White"))
        .onAppear {
            // Настраиваем callback для ошибки сервера
            viewModel.setErrorCallback {
                showServerError = true
            }
        }
        .task {
            print("🔍 StationsPickerView: Начинаем загрузку данных")
            print("🔍 StationsPickerView: networkMonitor.isConnected = \(networkMonitor.isConnected)")
            
            // Проверяем подключение к интернету
            if !networkMonitor.isConnected {
                print("🔍 StationsPickerView: Нет интернета, показываем ошибку")
                showNoInternet = true
                return
            }
            
            await viewModel.load(forCityTitle: cityTitle)
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            print("🔍 StationsPickerView: onChange сработал, isConnected = \(isConnected)")
            print("🔍 StationsPickerView: allStations.count до onChange = \(viewModel.allStations.count)")
            if !isConnected {
                showNoInternet = true
            } else if isConnected && showNoInternet {
                // Автоматически скрываем экран "Нет интернета" при восстановлении соединения
                showNoInternet = false
            }
            print("🔍 StationsPickerView: allStations.count после onChange = \(viewModel.allStations.count)")
        }
        .fullScreenCover(isPresented: $showNoInternet) {
            NoInternetView(onTabSelected: onTabSelected ?? { _ in })
        }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: onTabSelected ?? { _ in })
        }
    }
}

// MARK: - Helpers
private func displayText(city: String?, station: String?, placeholder: String) -> String {
    guard let city, !city.isEmpty else { return placeholder }
    if let station, !station.isEmpty { return "\(city) (\(station))" }
    return city
}
