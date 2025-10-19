//
//  MainScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab = 0
    @State private var showCityPicker = false
    @State private var fromCity: String? = nil
    @State private var toCity: String? = nil
    @State private var pickerTarget: PickerTarget? = nil
    
    var body: some View {
        ZStack {
            // Основной фон
            Color("White")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if selectedTab == 0 {
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
                                    Text(fromCity ?? "Откуда")
                                        .font(.system(size: 17))
                                        .foregroundColor(fromCity == nil ? Color("GrayUniversal") : Color("Black"))
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    pickerTarget = .from
                                    showCityPicker = true
                                }
                                HStack {
                                    Text(toCity ?? "Куда")
                                        .font(.system(size: 17))
                                        .foregroundColor(toCity == nil ? Color("GrayUniversal") : Color("Black"))
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
                    .fullScreenCover(isPresented: $showCityPicker) {
                        CityPickerView(
                            viewModel: CityPickerViewModel(),
                            onSelect: { city in
                                if pickerTarget == .from { fromCity = city.name } else { toCity = city.name }
                                showCityPicker = false
                            },
                            onCancel: {
                                showCityPicker = false
                            }
                        )
                    }

                    Spacer()
                } else {
                    // Экран настроек — заглушка
                    SettingsScreenView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                // Tab Bar с двумя вкладками
                VStack(spacing: 0) {
                    Divider()
                        .background(Color("GrayUniversal"))
                    
                    HStack {
                        Button(action: {
                            selectedTab = 0
                        }) {
                            Image("Schedule")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedTab == 0 ? Color("Black") : Color("GrayUniversal"))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            selectedTab = 1
                        }) {
                            Image("Settings")
                                .renderingMode(Image.TemplateRenderingMode.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundColor(selectedTab == 1 ? Color("Black") : Color("GrayUniversal"))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                    .background(Color("White"))
                }
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
    MainScreenView()
}


// MARK: - City Picker (MVVM, lightweight, no project file edits)

struct City: Identifiable, Equatable {
    let id = UUID()
    let name: String
}

final class CityPickerViewModel: ObservableObject {
    @Published var query: String = ""
    @Published private(set) var allCities: [City] = [
        City(name: "Москва"),
        City(name: "Санкт Петербург"),
        City(name: "Сочи"),
        City(name: "Горный воздух"),
        City(name: "Краснодар"),
        City(name: "Казань"),
        City(name: "Омск")
    ]

    var filtered: [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return allCities }
        return allCities.filter { $0.name.lowercased().contains(trimmed.lowercased()) }
    }
}

struct CityPickerView: View {
    @ObservedObject var viewModel: CityPickerViewModel
    let onSelect: (City) -> Void
    let onCancel: () -> Void
    @FocusState private var searchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme

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
            .background(colorScheme == .dark ? Color("GrayUniversal") : Color("LightGray"))
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
                List(viewModel.filtered) { city in
                    Button(action: { onSelect(city) }) {
                        HStack {
                            Text(city.name)
                                .foregroundColor(Color("Black"))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color("Black"))
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .background(Color("White"))
        .onAppear { DispatchQueue.main.async { UIResponder.currentFirstResponderBecomesFirst(text: viewModel) } }
    }
}

// Helper to focus first responder on appear (lightweight placeholder)
private extension UIResponder {
    static func currentFirstResponderBecomesFirst(text: CityPickerViewModel) { /* no-op; native focus оставим пользователю */ }
}
