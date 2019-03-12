//
//  SplashViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        view.backgroundColor = ThemeManager.currentTheme().mainColor
        verifyCredentials()
    }
    
    func verifyCredentials() {
        sharedAuth.credentialsManager.credentials { error, credentials in
            if error == nil, let credentials = credentials {
                if let accessToken = credentials.accessToken {
                    DispatchQueue.main.async {
                        let apiManager = APIManager.sharedInstance
                        if (apiManager.authToken != accessToken && apiManager.authToken != nil) {
                            ostelcoAPI.wipeResources()
                        }
                        
                        if (apiManager.authToken != accessToken) {
                            apiManager.authToken = "Bearer \(accessToken)"
                        }
                        
                        // TODO: New API does not handle refreshToken yet
                        /*
                        if let refreshToken = credentials.refreshToken {
                            ostelcoAPI.refreshToken = refreshToken
                        }
                        */
                        
                        self.showSpinner(onView: self.view)
                        apiManager.customer.load()
                            .onSuccess({ data in
                                // TODO: Redirect based on user state
                                print("**************************")
                                print(data)
                            })
                            .onFailure({ error in
                                if let statusCode = error.httpStatusCode {
                                    switch statusCode {
                                    case 404:
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "showSignUp", sender: self)
                                        }
                                    default:
                                        let alert = UIAlertController(title: "Error", message: error.userMessage, preferredStyle: .alert)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            })
                            .onCompletion({ _ in
                                self.removeSpinner()
                            })
                    }
                    
                    return
                }
            }
            self.showMessage(loggedIn: false)
            // TODO: Redirect to login screen. Remember to clean up any local state from authentication
            // AppDelegate.shared.rootViewController.switchToLogout() // Old redirect logic
        }
        
    }
    
    private func showMessage(loggedIn: Bool) {
        
        let alert: UIAlertController;
        
        if loggedIn {
            alert = UIAlertController(title: "Authentication", message: "You are logged in.", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Authentication", message: "You are not logged in.", preferredStyle: .alert)
        }
        
        presentAlert(alert: alert)
    }

    @objc private func presentAlert(alert: UIAlertController) {
        alert.addAction(UIAlertAction(title: "To login", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showLogin", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: {_ in
            DispatchQueue.main.async {
                sharedAuth.logout()
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "New user to sign up", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showSignUp", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "User with no ekyc to choose country", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showCountry", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "User with ekyc in prog to ekyc last screen", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showEKYCLastScreen", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "User with ekyc failed to ekyc oh no screen", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showEKYCOhNo", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "User with ekyc done to esim", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showESim", sender: self)
            }
        }))
        alert.addAction(UIAlertAction(title: "User with ekyc done and esim to home", style: .default, handler: {_ in
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showHome", sender: self)
            }
        }))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
}

