//
//  Tracker.swift
//  Tracker
//
//  Created by Никита Нагорный on 12.04.2025.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]?
    
    enum Weekday: Int, CaseIterable {
        case monday = 1
        case tuesday, wednesday, thursday, friday, saturday, sunday
    }
}
