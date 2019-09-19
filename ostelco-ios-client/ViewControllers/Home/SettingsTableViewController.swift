//
//  SettingsTableViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/15/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    enum MenuItem: Int {
        case PurchaseHistory
        case TermsAndConditions
        case PrivacyPolicy
        case LogOut
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuItem = MenuItem(rawValue: indexPath.item) else {
            showAlert(title: "Error", msg: "Invalid selection")
            return
        }
        
        switch menuItem {
        case .PurchaseHistory:
            performSegue(withIdentifier: "purchaseHistory", sender: self)
        case .TermsAndConditions:
            UIApplication.shared.open(ExternalLink.termsAndConditions.url)
        case .PrivacyPolicy:
            UIApplication.shared.open(ExternalLink.privacyPolicy.url)
        case .LogOut:
            let logOut = LogOutActionSheet(showingIn: self)
            self.presentActionSheet(logOut)
        }
    }
}
