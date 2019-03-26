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
                        let userManager = UserManager.sharedInstance
                        if (userManager.authToken != accessToken && userManager.authToken != nil) {
                            apiManager.wipeResources()
                            UserManager.sharedInstance.clear()
                        }
                        
                        if (userManager.authToken != accessToken) {
                            apiManager.authHeader = "Bearer \(accessToken)"
                            UserManager.sharedInstance.authToken = accessToken
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
                                if let user: CustomerModel = data.typedContent(ifNone: nil) {
                                    UserManager.sharedInstance.user = user
                                    // TODO: Should check user data and redirect based on user state, for now always assume ekyc user is missing ekyc
                                    DispatchQueue.main.async {
                                        self.performSegue(withIdentifier: "showCountry", sender: self)
                                    }
                                } else {
                                    preconditionFailure("Failed to parse user from server response.")
                                }
                            })
                            .onFailure({ error in
                                if let statusCode = error.httpStatusCode {
                                    switch statusCode {
                                    case 404:
                                        DispatchQueue.main.async {
                                            self.performSegue(withIdentifier: "showSignUp", sender: self)
                                        }
                                    default:
                                        preconditionFailure("Failed to fetch user profile from server: \(error.userMessage)")
                                    }
                                } else {
                                    preconditionFailure("Failed to fetch user profile from server: \(error.userMessage)")
                                }
                            })
                            .onCompletion({ _ in
                                self.removeSpinner()
                            })
                    }
                    
                    return
                }
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showSignUp", sender: self)
            }
        }
        
    }
}

