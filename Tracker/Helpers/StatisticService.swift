//
//  StatisticService.swift
//  Tracker
//
//  Created by Никита Нагорный on 07.10.2025.
//

import Foundation
import CoreData

final class StatisticService {
    
    private let dataManager: DataManager
    
    init(dataManager: DataManager = DataManager.shared) {
        self.dataManager = dataManager
    }
    
    func getBestPeriod() -> Int {
        let records = dataManager.fetchRecords()
        let dates = records.map { $0.date }
        
        guard !dates.isEmpty else { return 0 }
        
        let uniqueDates = Array(Set(dates.map { Calendar.current.startOfDay(for: $0) })).sorted()
        return calculateLongestStreak(dates: uniqueDates)
    }
    
    func getPerfectDays() -> Int {
        let records = dataManager.fetchRecords()
        let trackers = dataManager.fetchTrackers()
        
        guard !trackers.isEmpty else { return 0 }
        
        let recordsByDate = Dictionary(grouping: records) { record in
            Calendar.current.startOfDay(for: record.date)
        }
        
        var perfectDaysCount = 0
        
        for (date, dateRecords) in recordsByDate {
            let trackersForDate = trackers.filter { tracker in
                isTrackerScheduledForDate(tracker, date: date)
            }
            
            if !trackersForDate.isEmpty && dateRecords.count >= trackersForDate.count {
                perfectDaysCount += 1
            }
        }
        
        return perfectDaysCount
    }
    
    func getCompletedTrackers() -> Int {
        return dataManager.fetchRecords().count
    }
    
    func getAverageValue() -> Int {
        let records = dataManager.fetchRecords()
        let uniqueDates = Set(records.map { Calendar.current.startOfDay(for: $0.date) })
        
        guard !uniqueDates.isEmpty else { return 0 }
        
        return records.count / uniqueDates.count
    }
    
    private func calculateLongestStreak(dates: [Date]) -> Int {
        guard !dates.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<dates.count {
            let previousDate = dates[i - 1]
            let currentDate = dates[i]
            
            if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: previousDate),
               Calendar.current.isDate(nextDay, inSameDayAs: currentDate) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    private func isTrackerScheduledForDate(_ tracker: Tracker, date: Date) -> Bool {
        guard let schedule = tracker.schedule else {
            return true
        }
        
        let weekday = Calendar.current.component(.weekday, from: date)
        let adjustedWeekday = (weekday + 5) % 7 + 1
        return schedule.contains { $0.rawValue == adjustedWeekday }
    }
    
    func hasStatisticsData() -> Bool {
        return !dataManager.fetchRecords().isEmpty
    }
}
