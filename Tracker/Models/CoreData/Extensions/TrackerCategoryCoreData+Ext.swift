//
//  TrackerCategoryCoreData.swift
//  Tracker
//
//  Created by Никита Нагорный on 08.09.2025.
//

import UIKit
import CoreData

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
