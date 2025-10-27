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
            Color("AppWhite")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(0..<4) { index in
                                StoryCardView(isActive: index < 2)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 12)

                    ZStack(alignment: .trailing) {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color("BlueUniversal"))
                            .frame(height: 135)

                        HStack(spacing: 0) {
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
                            .padding(.vertical, 16) 
                            .frame(height: 103)
                            .background(Color("WhiteUniversal"))
                            .cornerRadius(20)
                          
                            Spacer()
                                .frame(width: 60)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)

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
        .navigationDestination(isPresented: $showCityPicker) {
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
            .toolbar(.hidden, for: .tabBar)
            .navigationBarHidden(true)
        }
        .task {
            guard didPrefetchDirectory == false else { return }
            didPrefetchDirectory = true
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            do { _ = try await directory.fetchAllCities() }
            catch {
                if error.localizedDescription.contains("network") ||
                   error.localizedDescription.contains("internet") ||
                   error.localizedDescription.contains("offline") {
                    onNoInternet()
                } else { onServerError() }
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
private enum PickerTarget { case from, to }


#Preview {
    MainScreenView(
        sessionManager: SessionManager(),
        onServerError: {},
        onNoInternet: {},
        onTabSelected: nil
    )
}


// MARK: - Сити пикер 

struct City: Identifiable, Equatable, Hashable {
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
            if error.localizedDescription.contains("network") || 
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                await MainActor.run { self.allCities = self.defaultCities }
            } else {
                onServerError?()
            }
        }
    }
    
    func simulateServerError() {
        onServerError?()
    }

    var filtered: [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return defaultCities }
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
    @State private var showServerError = false
    @StateObject private var stationsViewModel = StationsPickerViewModel() 

    var body: some View {
        VStack(spacing: 0) {
            Color("AppWhite")
                .frame(height: 12)
                .ignoresSafeArea(edges: .top)

            ZStack {
                Text("Выбор города")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("AppBlack"))
                    .multilineTextAlignment(.center)
                HStack {
                    Button(action: { onCancel() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("AppBlack"))
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
                    .foregroundColor(Color("AppBlack"))
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

            if viewModel.filtered.isEmpty && viewModel.query.isEmpty == false {
                VStack { 
                    Text("Город не найден")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("AppBlack"))
                        .multilineTextAlignment(.center)
                        .padding(.top, 180)
                    
                    /* Button("Тест: Ошибка сервера") {
                        viewModel.simulateServerError()
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("BlueUniversal"))
                    .padding(.top, 20)
                    
                    Spacer() */
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
                                        .foregroundColor(Color("AppBlack"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color("AppBlack"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
            .background(Color("AppWhite"))
                        }
                    }
                }
                .background(Color("AppWhite"))
            }
        }
        .background(Color("AppWhite"))
        .onAppear {
            viewModel.setErrorCallback {
                showServerError = true
            }
            
            DispatchQueue.main.async { UIResponder.currentFirstResponderBecomesFirst(text: viewModel) }
            Task { await viewModel.loadCities() }
        }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: onTabSelected ?? { _ in })
        }
        .navigationDestination(item: $selectedCity) { city in
            StationsPickerView(
                cityTitle: city.name,
                viewModel: stationsViewModel,
                onSelect: { station in
                    onSelect(CityStationSelection(city: city.name, station: station.title))
                    selectedCity = nil
                },
                onCancel: { selectedCity = nil },
                onTabSelected: onTabSelected
            )
            .toolbar(.hidden, for: .tabBar)
            .navigationBarHidden(true)
        }
    }
}

private extension UIResponder {
    static func currentFirstResponderBecomesFirst(text: CityPickerViewModel) { /* no-op; native focus оставим пользователю */ }
}

// MARK: - Основная кнопка под синим блоком
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

// MARK: - Выбор станции

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
        
        
        if currentCityTitle == cityTitle && !allStations.isEmpty {
            
            return
        }
        
        if isLoading {
            
            return
        }
        
        if currentCityTitle == cityTitle {
            
            return
        }
        
        await MainActor.run { 
            
            self.isLoading = true
            self.currentCityTitle = cityTitle
            self.query = "" 
        }
        defer { 
            
            Task { @MainActor in
                self.isLoading = false 
            }
        }
        do {
            
            let directory = DirectoryService(apikey: "50889f83-e54c-4e2e-b9b9-7d5fe468a025")
            let stations = try await directory.fetchStations(inCityTitle: cityTitle)
            let mapped = stations.map { Station(code: $0.yandexCode, title: $0.title) }
            
        await MainActor.run { 
            self.allStations = mapped 
            
        }
        } catch {
            if error.localizedDescription.contains("network") || 
               error.localizedDescription.contains("internet") ||
               error.localizedDescription.contains("offline") {
                await MainActor.run { self.allStations = [] }
            } else {
                onServerError?()
            }
        }
    }

    var filtered: [Station] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.isEmpty == false else { 
            
            return allStations 
        }
        let result = allStations.filter { $0.title.lowercased().contains(trimmed.lowercased()) }
        
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
    @State private var showServerError = false
    
    init(cityTitle: String, viewModel: StationsPickerViewModel, onSelect: @escaping (Station) -> Void, onCancel: @escaping () -> Void, onTabSelected: ((Int) -> Void)?) {
        self.cityTitle = cityTitle
        self.viewModel = viewModel
        self.onSelect = onSelect
        self.onCancel = onCancel
        self.onTabSelected = onTabSelected
        
    }

    var body: some View {
        VStack(spacing: 0) {
            Color("AppWhite").frame(height: 12).ignoresSafeArea(edges: .top)
            ZStack {
                Text("Выбор станции")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color("AppBlack"))
                HStack {
                    Button(action: { onCancel() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("AppBlack"))
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
                    .foregroundColor(Color("AppBlack"))
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
                                        .foregroundColor(Color("AppBlack"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color("AppBlack"))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 16)
                            }
                            .background(Color("AppWhite"))
                        }
                    }
                }
                .background(Color("AppWhite"))
            }
        }
        .background(Color("AppWhite"))
        .onAppear {
            viewModel.setErrorCallback {
                showServerError = true
            }
        }
        .task { await viewModel.load(forCityTitle: cityTitle) }
        .fullScreenCover(isPresented: $showServerError) {
            ServerErrorView(onTabSelected: onTabSelected ?? { _ in })
        }
    }
}

// MARK: - хелперы
private func displayText(city: String?, station: String?, placeholder: String) -> String {
    guard let city, !city.isEmpty else { return placeholder }
    if let station, !station.isEmpty { return "\(city) (\(station))" }
    return city
}
