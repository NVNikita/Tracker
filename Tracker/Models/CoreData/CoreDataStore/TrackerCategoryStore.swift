//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Никита Нагорный on 10.09.2025.
//

import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchCategories() -> [TrackerCategory] {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categoryCoreDataArray = try context.fetch(fetchRequest)
            return categoryCoreDataArray.compactMap { $0.toTrackerCategory() }
        } catch {
            print("Failed to fetch categories: \(error)")
            return []
        }
    }
    
    func addCategory(_ category: TrackerCategory) throws {
        let categoryCoreData = TrackerCategoryCoreData.create(from: category, context: context)
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
}
