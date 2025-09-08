//
//  TrackerRecordCoreData.swift
//  Tracker
//
//  Created by Никита Нагорный on 08.09.2025.
//

import UIKit
import CoreData

extension TrackerRecordCoreData {
    func toTrackerRecord() -> TrackerRecord? {
        guard let id = id, let date = date else { return nil }
        return TrackerRecord(id: id, date: date)
    }
    
    static func create(from record: TrackerRecord, context: NSManagedObjectContext) -> TrackerRecordCoreData {
        let recordCoreData = TrackerRecordCoreData(context: context)
        recordCoreData.id = record.id
        recordCoreData.date = record.date
        return recordCoreData
    }
}
