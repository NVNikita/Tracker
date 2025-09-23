//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData
import UIKit

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidChangeContent(_ changes: [DataManagerChange])
}

final class TrackerCategoryStore: NSObject {
    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>!
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
    }
    
    private func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "titleCategory", ascending: true)
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
    
    func fetchCategories() -> [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects.compactMap { $0.toTrackerCategory() }
    }
    
    func fetchCategoryTitles() -> [String] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }
        return objects.compactMap { $0.titleCategory }
    }
    
    func saveCategory(title: String) throws {
        let category = TrackerCategory(titleCategory: title, trackersArray: [])
        _ = TrackerCategoryCoreData.create(from: category, context: context)
        try context.save()
    }
    
    func deleteCategory(title: String) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titleCategory == %@", title)
        
        if let categoryCoreData = try context.fetch(fetchRequest).first {
            context.delete(categoryCoreData)
            try context.save()
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        _ = TrackerCategoryCoreData.create(from: category, context: context)
        try context.save()
    }
    
    func updateCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titleCategory == %@", category.titleCategory)
        
        if let categoryCoreData = try context.fetch(fetchRequest).first {
            categoryCoreData.titleCategory = category.titleCategory
            try context.save()
        }
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "titleCategory == %@", category.titleCategory)
        
        if let categoryCoreData = try context.fetch(fetchRequest).first {
            context.delete(categoryCoreData)
            try context.save()
        }
    }
    
    func numberOfCategories() -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func category(at indexPath: IndexPath) -> TrackerCategory? {
        let categoryCoreData = fetchedResultsController.object(at: indexPath)
        return categoryCoreData.toTrackerCategory()
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
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
            delegate?.trackerCategoryStoreDidChangeContent(changes)
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
            delegate?.trackerCategoryStoreDidChangeContent(changes)
        }
    }
}

extension TrackerCategoryCoreData {
    func toTrackerCategory() -> TrackerCategory? {
        guard let title = titleCategory else { return nil }
        
        let trackersArray = (trackers?.allObjects as? [TrackerCoreData])?
            .compactMap { $0.toTracker() } ?? []
        
        return TrackerCategory(
            titleCategory: title,
            trackersArray: trackersArray
        )
    }
    
    static func create(from category: TrackerCategory, context: NSManagedObjectContext) -> TrackerCategoryCoreData {
        let categoryCoreData = TrackerCategoryCoreData(context: context)
        categoryCoreData.titleCategory = category.titleCategory
        
        let trackersCoreData = category.trackersArray.map { tracker in
            TrackerCoreData.create(from: tracker, context: context)
        }
        
        categoryCoreData.trackers = NSSet(array: trackersCoreData)
        
        return categoryCoreData
    }
}
