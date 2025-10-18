//
//  MainScreenView.swift
//  Travel Schedule
//
//  Created by Ульта on 18.10.2025.
//

import SwiftUI

struct MainScreenView: View {
    @State private var selectedTab = 0
    
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
                                    Text("Откуда")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color("GrayUniversal"))
                                    Spacer()
                                }
                                HStack {
                                    Text("Куда")
                                        .font(.system(size: 17))
                                        .foregroundColor(Color("GrayUniversal"))
                                    Spacer()
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
                            // Логика переключения будет позже
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

#Preview {
    MainScreenView()
}

