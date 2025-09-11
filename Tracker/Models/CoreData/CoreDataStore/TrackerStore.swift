//
//  TrackerStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchTrackers() -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackerCoreDataArray = try context.fetch(fetchRequest)
            return trackerCoreDataArray.compactMap { $0.toTracker() }
        } catch {
            print("Failed to fetch trackers: \(error)")
            return []
        }
    }
    
    func addTracker(_ tracker: Tracker) throws {
        _ = TrackerCoreData.create(from: tracker, context: context)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            trackerCoreData.name = tracker.name
            trackerCoreData.emoji = tracker.emoji
            
            if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: tracker.color, requiringSecureCoding: false) {
                trackerCoreData.colorData = colorData
            }
            
            if let schedule = tracker.schedule,
               let scheduleData = try? NSKeyedArchiver.archivedData(withRootObject: schedule, requiringSecureCoding: false) {
                trackerCoreData.schedule = scheduleData
            }
            
            try context.save()
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", tracker.id as CVarArg)
        
        if let trackerCoreData = try context.fetch(fetchRequest).first {
            context.delete(trackerCoreData)
            try context.save()
        }
    }
}
