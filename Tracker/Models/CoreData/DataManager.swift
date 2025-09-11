//
//  DataManager.swift
//  Tracker
//
//  Created by Никита Нагорный on 11.09.2025.
//

import CoreData

final class DataManager {
    static let shared = DataManager()
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TrackerCoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var trackerStore: TrackerStore = {
        return TrackerStore(context: context)
    }()
    
    private lazy var categoryStore: TrackerCategoryStore = {
        return TrackerCategoryStore(context: context)
    }()
    
    private lazy var recordStore: TrackerRecordStore = {
        return TrackerRecordStore(context: context)
    }()
    
    private init() {}
    
    func fetchCategories() -> [TrackerCategory] {
        return categoryStore.fetchCategories()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        do {
            return try recordStore.fetchRecords()
        } catch {
            print("Failed to fetch records: \(error)")
            return []
        }
    }
    
    func addTracker(_ tracker: Tracker, to categoryTitle: String) {
        do {
            let categoryFetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
            categoryFetchRequest.predicate = NSPredicate(format: "titleCategory == %@", categoryTitle)
            
            let categoryCoreData: TrackerCategoryCoreData
            
            if let existingCategory = try context.fetch(categoryFetchRequest).first {
                categoryCoreData = existingCategory
            } else {
                categoryCoreData = TrackerCategoryCoreData(context: context)
                categoryCoreData.titleCategory = categoryTitle
            }
            
            let trackerCoreData = TrackerCoreData.create(from: tracker, context: context)
            categoryCoreData.addToTrackers(trackerCoreData)
            
            try context.save()
            
            NotificationCenter.default.post(name: NSNotification.Name("TrackersUpdated"), object: nil)
            
        } catch {
            print("Failed to add tracker: \(error)")
        }
    }
    
    func toggleTrackerCompletion(_ tracker: Tracker, on date: Date) {
        do {
            let records = try recordStore.fetchRecords(for: tracker.id)
            let recordForDate = records.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
            
            if let record = recordForDate {
                try recordStore.deleteRecord(record)
            } else {
                let newRecord = TrackerRecord(id: tracker.id, date: date)
                try recordStore.addRecord(newRecord)
            }
        } catch {
            print("Failed to toggle tracker completion: \(error)")
        }
    }
    
    func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        do {
            let records = try recordStore.fetchRecords(for: tracker.id)
            return records.contains { Calendar.current.isDate($0.date, inSameDayAs: date) }
        } catch {
            print("Failed to check tracker completion: \(error)")
            return false
        }
    }
    
    func completedDaysCount(for tracker: Tracker) -> Int {
        do {
            let records = try recordStore.fetchRecords(for: tracker.id)
            return records.count
        } catch {
            print("Failed to get completed days count: \(error)")
            return 0
        }
    }
}
