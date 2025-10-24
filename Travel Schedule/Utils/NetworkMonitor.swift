//
//  NetworkMonitor.swift
//  Travel Schedule
//
//  Created by Ульта on 23.10.2025.
//

import Foundation
import Network
import SwiftUI

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var probeWorkItem: DispatchWorkItem?
    
    @Published var isConnected = true
    
    init() {
        print("🔍 NetworkMonitor: Инициализация")
        monitor.pathUpdateHandler = { [weak self] path in
            print("🔍 NetworkMonitor: pathUpdateHandler вызван")
            DispatchQueue.main.async {
                let wasConnected = self?.isConnected ?? true
                let isNowConnected = path.status == .satisfied
                
                print("🔍 NetworkMonitor: Статус изменился: \(wasConnected) -> \(isNowConnected)")
                print("🔍 NetworkMonitor: path.status = \(path.status)")
                print("🔍 NetworkMonitor: path.status == .satisfied = \(path.status == .satisfied)")
                
                // Логируем только если статус действительно изменился
                if wasConnected != isNowConnected {
                    print("🔍 NetworkMonitor: РЕАЛЬНОЕ изменение: \(wasConnected) -> \(isNowConnected)")
                }
                
                self?.isConnected = isNowConnected

                // Если сети нет — планируем разовую проверку через HTTP probe,
                // т.к. на некоторых конфигурациях удовлетворённый путь приходит
                // только после первой удачной попытки сети
                if isNowConnected == false {
                    self?.scheduleProbe()
                } else {
                    // Отменяем запланированный probe при восстановлении
                    self?.probeWorkItem?.cancel()
                    self?.probeWorkItem = nil
                }
            }
        }
        monitor.start(queue: queue)
        print("🔍 NetworkMonitor: Мониторинг запущен")
    }
    
    deinit {
        monitor.cancel()
    }

    // MARK: - Проверка подключения для разблокировки пути в некоторых конфигурациях
    private func scheduleProbe() {
        probeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            let url = URL(string: "https://clients3.google.com/generate_204")!
            let config = URLSessionConfiguration.ephemeral
            config.timeoutIntervalForRequest = 2
            config.timeoutIntervalForResource = 3
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: url) { _, response, error in
                DispatchQueue.main.async {
                    if let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) {
                        let pathSatisfied = self.monitor.currentPath.status == .satisfied
                        print("🔍 NetworkMonitor: PROBE успех, pathSatisfied = \(pathSatisfied)")
                        // Сразу считаем сеть доступной по успешному HTTP (для UX),
                        // чтобы мгновенно скрыть экран. Путь догонит чуть позже.
                        self.isConnected = true
                        self.probeWorkItem = nil
                    } else if let error = error {
                        print("🔍 NetworkMonitor: PROBE ошибка: \(error.localizedDescription)")
                        // Если ещё нет сети — пробуем снова через 1 сек.
                        if self.isConnected == false {
                            self.rescheduleProbe()
                        }
                    } else {
                        print("🔍 NetworkMonitor: PROBE нет ответа")
                        if self.isConnected == false {
                            self.rescheduleProbe()
                        }
                    }
                }
            }
            task.resume()
        }
        probeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: work)
    }

    private func rescheduleProbe() {
        // Не множим задачи: если уже есть активный workItem — не добавляем ещё один
        guard probeWorkItem == nil else { return }
        scheduleProbe()
    }
}
