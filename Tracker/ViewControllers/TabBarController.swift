//
//  TapBarController.swift
//  Tracker
//
//  Created by Никита Нагорный on 26.03.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackerViewController()
        let statisticsViewController = StatisticViewController()
        
        let trackersNavController = UINavigationController(rootViewController: trackersViewController)
        
        trackersNavController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "tapBarImageStatistics"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "tapBarImageTrakers"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavController, statisticsViewController]
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.borderWidth = 0.3
    }
}
