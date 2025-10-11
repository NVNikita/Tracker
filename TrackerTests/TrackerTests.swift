//
//  MainTabBarControllerSnapshotTests.swift
//  TrackerTests
//
//  Created by Никита Нагорный on 26.03.2025.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TabBarControllerSnapshotTests: XCTestCase {
    
    private var testWindow: UIWindow!
    
    override func setUp() {
        super.setUp()
        
        testWindow = UIWindow(frame: UIScreen.main.bounds)
        testWindow.makeKeyAndVisible()
    }
    
    override func tearDown() {
        testWindow = nil
        super.tearDown()
    }
    
    func test_mainTabBarController_lightTheme_appearance() {
        // Given
        testWindow.overrideUserInterfaceStyle = .light
        let tabBarController = TabBarController()
        
        // When
        testWindow.rootViewController = tabBarController
        tabBarController.loadViewIfNeeded()
        
        // Wait for UI to be fully rendered
        let expectation = XCTestExpectation(description: "UI rendering completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        assertSnapshot(
            of: tabBarController,
            as: .image(on: .iPhone13Pro, traits: .init(userInterfaceStyle: .light)),
            named: "light_theme",
            record: false
        )
    }
    
    func test_mainTabBarController_darkTheme_appearance() {
        // Given
        testWindow.overrideUserInterfaceStyle = .dark
        let tabBarController = TabBarController()
        
        // When
        testWindow.rootViewController = tabBarController
        tabBarController.loadViewIfNeeded()
        
        // Wait for UI to be fully rendered
        let expectation = XCTestExpectation(description: "UI rendering completed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        
        // Then
        assertSnapshot(
            of: tabBarController,
            as: .image(on: .iPhone13Pro, traits: .init(userInterfaceStyle: .dark)),
            named: "dark_theme",
            record: false
        )
    }
}
