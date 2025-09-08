//
//  TrackerCoreData.swift
//  Tracker
//
//  Created by Никита Нагорный on 08.09.2025.
//

import UIKit
import CoreData

extension TrackerCoreData {
    func toTracker() -> Tracker? {
        guard let id = id,
              let name = name,
              let emoji = emoji,
              let colorData = colorData else {
            return nil
        }
        
        var schedule: [Tracker.Weekday]?
        if let scheduleData = self.schedule {
            schedule = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: scheduleData) as? [Tracker.Weekday]
        }
        
        guard let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) else {
            return nil
        }
        
        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
    
    static func create(from tracker: Tracker, context: NSManagedObjectContext) -> TrackerCoreData {
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        
        if let colorData = try? NSKeyedArchiver.archivedData(withRootObject: tracker.color, requiringSecureCoding: false) {
            trackerCoreData.colorData = colorData
        }
        
        if let schedule = tracker.schedule,
           let scheduleData = try? NSKeyedArchiver.archivedData(withRootObject: schedule, requiringSecureCoding: false) {
            trackerCoreData.schedule = scheduleData
        }
        
        return trackerCoreData
    }
}
