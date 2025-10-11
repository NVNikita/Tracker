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
        let statisticsNavController = UINavigationController(rootViewController: statisticsViewController)
        
        trackersNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.trackers", comment: "TabBatItem trackers text"),
            image: UIImage(named: "tapBarImageStatistics"),
            selectedImage: nil
        )
        
        statisticsNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.statistics", comment: "TabBatItem statistics text"),
            image: UIImage(named: "tapBarImageTrakers"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersNavController, statisticsNavController]
        self.tabBar.layer.masksToBounds = true
        self.tabBar.layer.borderWidth = 0.3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AppMetricaHelper.sendEvent(event: "open", screen: "Main")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppMetricaHelper.sendEvent(event: "close", screen: "Main")
    }
}
