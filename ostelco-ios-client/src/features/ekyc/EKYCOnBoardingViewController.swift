//
//  EKYCOnBoardingViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EKYCOnBoardingViewController: UIViewController {
    
    @IBAction func needHelpTapped(_ sender: Any) {
        showNeedHelpActionSheet()
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        performSegue(withIdentifier: "showEKYCViewController", sender: self)
    }
}
