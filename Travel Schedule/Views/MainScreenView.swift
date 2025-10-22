//
//  MainScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI
import OpenAPIURLSession

struct MainScreenView: View {
    let onServerError: () -> Void
    let onNoInternet: () -> Void
    
    @State private var showCityPicker = false
    @State private var fromCity: String? = nil
    @State private var fromStation: String? = nil
    @State private var toCity: String? = nil
    @State private var toStation: String? = nil
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
                                    Text(displayText(city: fromCity, station: fromStation, placeholder: "Откуда"))
                                        .font(.system(size: 17))
                                        .foregroundColor(fromCity == nil ? Color("GrayUniversal") : Color("BlackUniversal"))
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    pickerTarget = .from
                                    showCityPicker = true
                                }
                                HStack {
                                    Text(displayText(city: toCity, station: toStation, placeholder: "Куда"))
                                        .font(.system(size: 17))
                                        .foregroundColor(toCity == nil ? Color("GrayUniversal") : Color("BlackUniversal"))
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
                            swap(&fromCity, &toCity)
                            swap(&fromStation, &toStation)
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
                    if (fromCity?.isEmpty == false) && (toCity?.isEmpty == false) {
                        SearchPrimaryButton(title: "Найти") {
                            showCarriers = true
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.2), value: fromCity)
                        .animation(.easeOut(duration: 0.2), value: toCity)
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
                        fromCity = selection.city
                        fromStation = selection.station
                    } else {
                        toCity = selection.city
                        toStation = selection.station
                    }
                    showCityPicker = false
                },
                onCancel: {
                    showCityPicker = false
                }
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
            if let fromCity = fromCity,
               let fromStation = fromStation,
               let toCity = toCity,
               let toStation = toStation {
                CarriersScreenView(
                    fromCity: fromCity,
                    fromStation: fromStation,
                    toCity: toCity,
                    toStation: toStation,
                    onBack: {
                        showCarriers = false
                    }
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
        onServerError: {},
        onNoInternet: {}
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

    func loadCities() async {
        do {
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            let cities = try await directory.fetchAllCities()
            let mapped = cities.map { City(name: $0.title) }
            await MainActor.run { self.allCities = mapped.isEmpty ? self.defaultCities : mapped }
        } catch {
            await MainActor.run { self.allCities = self.defaultCities }
        }
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
    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCity: City? = nil
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternet = false

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
            DispatchQueue.main.async { UIResponder.currentFirstResponderBecomesFirst(text: viewModel) }
            Task { await viewModel.loadCities() }
        }
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
        .fullScreenCover(item: $selectedCity) { city in
            StationsPickerView(
                cityTitle: city.name,
                viewModel: StationsPickerViewModel(),
                onSelect: { station in
                    onSelect(CityStationSelection(city: city.name, station: station.title))
                    selectedCity = nil
                },
                onCancel: { selectedCity = nil }
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

    func load(forCityTitle cityTitle: String) async {
        await MainActor.run { 
            self.isLoading = true
            self.allStations = [] // Очищаем предыдущие станции перед загрузкой новых
            self.query = "" // Очищаем поисковый запрос
        }
        defer { Task { await MainActor.run { self.isLoading = false } } }
        do {
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            let stations = try await directory.fetchStations(inCityTitle: cityTitle)
            let mapped = stations.map { Station(code: $0.yandexCode, title: $0.title) }
            await MainActor.run { 
                self.allStations = mapped 
            }
        } catch {
            await MainActor.run { self.allStations = [] }
        }
    }

    var filtered: [Station] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return allStations }
        return allStations.filter { $0.title.lowercased().contains(trimmed.lowercased()) }
    }
}

struct StationsPickerView: View {
    let cityTitle: String
    @ObservedObject var viewModel: StationsPickerViewModel
    let onSelect: (Station) -> Void
    let onCancel: () -> Void
    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var showNoInternet = false

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
        .task { await viewModel.load(forCityTitle: cityTitle) }
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
}

// MARK: - Helpers
private func displayText(city: String?, station: String?, placeholder: String) -> String {
    guard let city, !city.isEmpty else { return placeholder }
    if let station, !station.isEmpty { return "\(city) (\(station))" }
    return city
}
