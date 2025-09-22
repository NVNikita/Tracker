//
//  CategoryManager.swift
//  Tracker
//
//  Created by Никита Нагорный on 22.09.2025.
//

import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    private init() {}
    
    private let categoriesKey = "savedCategories"
    
    var categories: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: categoriesKey) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: categoriesKey)
        }
    }
    
    func addCategory(_ category: String) {
        var currentCategories = categories
        if !currentCategories.contains(category) && !category.trimmingCharacters(in: .whitespaces).isEmpty {
            currentCategories.append(category)
            categories = currentCategories
        }
    }
    
    func removeCategory(_ category: String) {
        var currentCategories = categories
        currentCategories.removeAll { $0 == category }
        categories = currentCategories
    }
}
