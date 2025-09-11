//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        
        do {
            let recordCoreDataArray = try context.fetch(fetchRequest)
            return recordCoreDataArray.compactMap { $0.toTrackerRecord() }
        } catch {
            throw error
        }
    }
    
    func addRecord(_ record: TrackerRecord) throws {
        _ = TrackerRecordCoreData.create(from: record, context: context)
        try context.save()
    }
    
    func deleteRecord(_ record: TrackerRecord) throws {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@ AND date == %@", record.id as CVarArg, record.date as CVarArg)
        
        if let recordCoreData = try context.fetch(fetchRequest).first {
            context.delete(recordCoreData)
            try context.save()
        } else {
            throw NSError(domain: "TrackerRecordStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Record not found"])
        }
    }
    
    func fetchRecords(for trackerId: UUID) throws -> [TrackerRecord] {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", trackerId as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.compactMap { $0.toTrackerRecord() }
        } catch {
            throw error
        }
    }
}
