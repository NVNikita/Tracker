//
//  CategoryViewModel.swift
//  Tracker
//
//  Created by Никита Нагорный on 23.09.2025.
//

import Foundation

final class CategoryViewModel {
    private let categoryStore: TrackerCategoryStore
    
    var onCategoriesUpdate: (() -> Void)?
    
    private var categories: [String] = [] {
        didSet {
            onCategoriesUpdate?()
        }
    }
    
    var shouldShowPlaceholder: Bool {
        return categories.isEmpty
    }
    
    var numberOfCategories: Int {
        return categories.count
    }
    
    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
    }
    
    func loadCategories() {
        categories = categoryStore.fetchCategoryTitles()
    }
    
    func saveCategory(_ title: String) {
        do {
            try categoryStore.saveCategory(title: title)
            loadCategories()
        } catch {
            print("Ошибка сохранения категории: \(error)")
        }
    }
    
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        let categoryTitle = categories[index]
        
        do {
            try categoryStore.deleteCategory(title: categoryTitle)
            loadCategories()
        } catch {
            print("Ошибка удаления категории: \(error)")
        }
    }
    
    func getCategoryTitle(at index: Int) -> String {
        guard index < categories.count else { return "" }
        return categories[index]
    }
    
    func selectCategory(at index: Int) -> String {
        guard index < categories.count else { return "" }
        return categories[index]
    }
}
