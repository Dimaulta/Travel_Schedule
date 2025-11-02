//
//  StoriesViewModel.swift
//  Travel Schedule
//
//  Created by Ульта on 02.11.2025.
//

import SwiftUI
import Combine

struct StoryItem: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    let title: String
    let description: String
}

@MainActor
final class StoriesViewModel: ObservableObject {
    @Published private(set) var items: [StoryItem] = []
    @Published var progress: CGFloat = 0
    @Published var isPlaying: Bool = false
    
    private var timer: Timer.TimerPublisher = Timer.publish(every: 0.05, on: .main, in: .common)
    private var cancellable: Cancellable?
    
    private let secondsPerStory: TimeInterval = 5
    
    init() {
        items = [
            StoryItem(imageName: "storyimg01", title: "Первая история", description: "Утренний поезд уносит нас навстречу новому дню, но я сеголдня не совершу ошибку как миллионы нетакусек"),
            StoryItem(imageName: "storyimg02", title: "Вторая история", description: "Брат запомни: лишь тот кто не хочет идти никуда, тот никуда не идет"),
            StoryItem(imageName: "storyimg03", title: "Третья история", description: "Паровозик из одного советского мультика который всё время сходил с рельс и нюхал не всегда был прав "),
            StoryItem(imageName: "", title: "Четвертая история", description: "Тут тоже мог быть текст, но боже как мне лень"),
            StoryItem(imageName: "", title: "Пятая история", description: "Зачем я это делаю, ради чего это всё происходит?"),
        ]
    }
    
    func start(from index: Int) {
        let count = max(1, items.count)
        progress = CGFloat(index) / CGFloat(count)
        play()
    }
    
    func play() {
        guard !isPlaying else { return }
        isPlaying = true
        timer = Timer.publish(every: 0.05, on: .main, in: .common)
        cancellable = timer.connect()
    }
    
    func pause() {
        isPlaying = false
        cancellable?.cancel()
    }
    
    func stop() {
        pause()
        progress = 0
    }
    
    func tick() -> Bool {
        guard isPlaying else { return false }
        let perTick = 1.0 / CGFloat(items.count) / CGFloat(secondsPerStory / 0.05)
        var next = progress + perTick
        if next >= 1 {
            // если дошли до конца последней сторис — закрываем плеер
            if currentIndex >= items.count - 1 { isPlaying = false; return true }
            next = CGFloat(currentIndex + 1) / CGFloat(items.count)
        }
        progress = next
        return false
    }
    
    func advanceToNextStory() {
        let count = max(1, items.count)
        let idx = currentIndex
        if idx >= count - 1 {
            // последняя сторис — оставим на месте; плеер закроет вызывающая сторона
            progress = 1
        } else {
            progress = CGFloat(idx + 1) / CGFloat(count)
        }
    }

    func advanceToPrevStory() {
        let count = max(1, items.count)
        let idx = currentIndex
        if idx <= 0 {
            progress = 0
        } else {
            progress = CGFloat(idx - 1) / CGFloat(count)
        }
    }
    
    var currentIndex: Int {
        let idx = Int(progress * CGFloat(items.count))
        return min(max(0, idx), max(0, items.count - 1))
    }
}


