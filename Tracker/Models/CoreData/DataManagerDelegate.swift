//
//  DataManagerDelegate.swift
//  Tracker
//
//  Created by Никита Нагорный on 11.09.2025.
//

import Foundation

protocol DataManagerDelegate: AnyObject {
    func didUpdateTrackers(_ changes: [DataManagerChange])
    func didUpdateCategories(_ changes: [DataManagerChange])
    func didUpdateRecords(_ changes: [DataManagerChange])
}

enum DataManagerChange {
    case insert(IndexPath)
    case delete(IndexPath)
    case update(IndexPath)
    case move(IndexPath, IndexPath)
    case insertSection(Int)
    case deleteSection(Int)
}
