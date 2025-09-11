//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStoreDidChangeContent(_ changes: [DataManagerChange])
}

final class TrackerRecordStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>!
    
    weak var delegate: TrackerRecordStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: false)
        ]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    func fetchRecords() throws -> [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects.compactMap { $0.toTrackerRecord() }
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
    
    func numberOfRecords() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func record(at indexPath: IndexPath) -> TrackerRecord? {
        let recordCoreData = fetchedResultsController.object(at: indexPath)
        return recordCoreData.toTrackerRecord()
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                   didChange anObject: Any,
                   at indexPath: IndexPath?,
                   for type: NSFetchedResultsChangeType,
                   newIndexPath: IndexPath?) {
        
        var changes: [DataManagerChange] = []
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                changes.append(.insert(newIndexPath))
            }
        case .delete:
            if let indexPath = indexPath {
                changes.append(.delete(indexPath))
            }
        case .update:
            if let indexPath = indexPath {
                changes.append(.update(indexPath))
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                changes.append(.move(indexPath, newIndexPath))
            }
        @unknown default:
            break
        }
        
        if !changes.isEmpty {
            delegate?.trackerRecordStoreDidChangeContent(changes)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                   didChange sectionInfo: NSFetchedResultsSectionInfo,
                   atSectionIndex sectionIndex: Int,
                   for type: NSFetchedResultsChangeType) {
        
        var changes: [DataManagerChange] = []
        
        switch type {
        case .insert:
            changes.append(.insertSection(sectionIndex))
        case .delete:
            changes.append(.deleteSection(sectionIndex))
        default:
            break
        }
        
        if !changes.isEmpty {
            delegate?.trackerRecordStoreDidChangeContent(changes)
        }
    }
}
