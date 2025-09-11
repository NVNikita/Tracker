//
//  TrackerStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData

protocol TrackerStoreDelegate: AnyObject {
    func trackerStoreDidChangeContent(_ changes: [DataManagerChange])
}

final class TrackerStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>!
    
    weak var delegate: TrackerStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "name", ascending: true)
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
    
    func fetchTrackers() -> [Tracker] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects.compactMap { $0.toTracker() }
    }
    
    func fetchTrackers(in category: TrackerCategory) -> [Tracker] {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "category.titleCategory == %@", category.titleCategory)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let trackers = try context.fetch(fetchRequest)
            return trackers.compactMap { $0.toTracker() }
        } catch {
            print("Failed to fetch trackers in category: \(error)")
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
    
    func numberOfTrackers() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerCoreData.toTracker()
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
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
            delegate?.trackerStoreDidChangeContent(changes)
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
            delegate?.trackerStoreDidChangeContent(changes)
        }
    }
}
