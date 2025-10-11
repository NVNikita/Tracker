//
//  Untitled.swift
//  Tracker
//
//  Created by Никита Нагорный on 09.10.2025.
//

import Foundation
import AppMetricaCore

final class AppMetricaHelper {
    static func sendEvent(event: String, screen: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]
        
        if let item = item {
            params["item"] = item
        }
        
        print("ANALYTICS EVENT: \(params)")
        
        
        AppMetrica.reportEvent(name: "analytics_event", parameters: params)
    }
}
