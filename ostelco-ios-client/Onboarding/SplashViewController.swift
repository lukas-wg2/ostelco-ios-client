//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, StoryboardLoadable {
    static let storyboard: Storyboard = .splash
    static let isInitialViewController = false
    
    @IBOutlet private weak var imageView: UIImageView!
    var spinnerView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = OstelcoColor.oyaBlue.toUIColor
    }
}
