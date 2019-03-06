//
//  ESIMOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class ESIMOnBoardingViewController: UIViewController {
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "showESIMInstructions", sender: self)
    }
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
}
