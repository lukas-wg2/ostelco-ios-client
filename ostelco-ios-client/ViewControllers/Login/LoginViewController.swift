//
//  LoginViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import OstelcoStyles
import UIKit
import Firebase

class LoginViewController: UIViewController {
    var spinnerView: UIView?
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    
    /// Has to be set up through `prepareForSegue` when this VC is loaded
    // swiftlint:disable:next implicitly_unwrapped_optional
    private var pageController: UIPageViewController!
    
    private lazy var dataSource: PageControllerDataSource = {
        let pages = OnboardingPage.allCases.map { $0.viewController }
        return PageControllerDataSource(pageController: self.pageController,
                                        viewControllers: pages,
                                        pageIndicatorTintColor: OstelcoColor.paleGrey.toUIColor,
                                        currentPageIndicatorTintColor: OstelcoColor.oyaBlue.toUIColor,
                                        delegate: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let index = self.dataSource.currentIndex
        self.configureButtonTitle(for: index)
        self.logoImageView.tintColor = OstelcoColor.oyaBlue.toUIColor
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageController = segue.destination as? UIPageViewController {
            self.pageController = pageController
        }
    }
    
    private func configureButtonTitle(for index: Int) {
        if index == (OnboardingPage.allCases.count - 1) {
            // This is the last page.
            self.primaryButton.setTitle("Sign In", for: .normal)
        } else {
            self.primaryButton.setTitle("Next", for: .normal)
        }
    }
    
    @IBAction private func primaryButtonTapped(_ sender: UIButton) {
        Analytics.logEvent("button_tapped", parameters: [
            "newValue": sender.title(for: .normal)!
            ])
        
        let index = self.dataSource.currentIndex
        if index == (OnboardingPage.allCases.count - 1) {
            self.signInTapped()
        } else {
            self.dataSource.goToNextPage()
        }
    }
    
    private func signInTapped() {
        UIApplication.shared.typedDelegate.rootCoordinator
            .navigate(to: .email, from: self, animated: true)
    }
}

extension LoginViewController: PageControllerDataSourceDelegate {
 
    func pageChanged(to index: Int) {
        self.configureButtonTitle(for: index)
    }
}

extension LoginViewController: StoryboardLoadable {
    
    static var storyboard: Storyboard {
        return .login
    }
    
    static var isInitialViewController: Bool {
        return true
    }
}
