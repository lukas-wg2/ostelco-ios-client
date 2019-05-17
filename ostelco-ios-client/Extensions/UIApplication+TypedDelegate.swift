//
//  UIApplication+TypedDelegate.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/17/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// The current application delegate cast to the proper type.
    var typedDelegate: AppDelegate {
        guard let typed = self.delegate as? AppDelegate else {
            fatalError("App delegate is not of proper type!")
        }
        
        return typed
    }
    
    /// Opens the settings for this application.
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            fatalError("Could not construct settings URL!")
        }

        UIApplication.shared.open(settingsURL)
    }
}
