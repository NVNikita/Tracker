//
//  DataManager.swift
//  Tracker
//
//  Created by Никита Нагорный on 11.09.2025.
//

import CoreData
import UIKit

final class DataManager: NSObject {
    static let shared = DataManager()
    
    weak var delegate: DataManagerDelegate?
    
    lazy var persistentContainer: NSPersistentContainer = {
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
        let store = TrackerStore(context: context)
        store.delegate = self
        return store
    }()
    
    private lazy var categoryStore: TrackerCategoryStore = {
        let store = TrackerCategoryStore(context: context)
        store.delegate = self
        return store
    }()
    
    private lazy var recordStore: TrackerRecordStore = {
        let store = TrackerRecordStore(context: context)
        store.delegate = self
        return store
    }()
    
    private override init() {}
    
    func fetchCategories() -> [TrackerCategory] {
        return categoryStore.fetchCategories()
    }
    
    func fetchTrackers() -> [Tracker] {
        return trackerStore.fetchTrackers()
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
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            let records = try recordStore.fetchRecords(for: tracker.id)
            for record in records {
                try recordStore.deleteRecord(record)
            }
            
            try trackerStore.deleteTracker(tracker)
            
        } catch {
            print("Failed to delete tracker: \(error)")
        }
    }
}

extension DataManager: TrackerStoreDelegate {
    func trackerStoreDidChangeContent(_ changes: [DataManagerChange]) {
        delegate?.didUpdateTrackers(changes)
    }
}

extension DataManager: TrackerCategoryStoreDelegate {
    func trackerCategoryStoreDidChangeContent(_ changes: [DataManagerChange]) {
        delegate?.didUpdateCategories(changes)
    }
}

extension DataManager: TrackerRecordStoreDelegate {
    func trackerRecordStoreDidChangeContent(_ changes: [DataManagerChange]) {
        delegate?.didUpdateRecords(changes)
    }
}
