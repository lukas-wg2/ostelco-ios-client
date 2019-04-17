//
//  UIViewController+UIActivityIndicator.swift
//  ostelco-ios-client
//
//  Created by mac on 3/5/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

// ref: https://github.com/vincechan/SwiftLoadingIndicator/blob/master/SwiftLoadingIndicator/LoadingIndicatorView.swift

extension UIViewController {
    func showSpinner(onView: UIView, loadingText: String? = nil) -> UIView {
        
        // Create the overlay
        let overlay = UIView()
        overlay.alpha = 0
        overlay.backgroundColor = UIColor.white
        overlay.translatesAutoresizingMaskIntoConstraints = false
        onView.addSubview(overlay)
        onView.bringSubviewToFront(overlay)
        
        overlay.widthAnchor.constraint(equalTo: onView.widthAnchor).isActive = true
        overlay.heightAnchor.constraint(equalTo: onView.heightAnchor).isActive = true
        
        // Create and animate the activity indicator
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.color = .black
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        
        // Create label
        if let textString = loadingText {
            let label = UILabel()
            label.text = textString
            label.textColor = UIColor.black
            overlay.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.bottomAnchor.constraint(equalTo: indicator.topAnchor, constant: -32).isActive = true
            label.centerXAnchor.constraint(equalTo: indicator.centerXAnchor).isActive = true
        }
        
        // Animate the overlay to show
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.5)
        overlay.alpha = overlay.alpha > 0 ? 0 : 0.88
        UIView.commitAnimations()
        
        return overlay
    }
    
    func removeSpinner(_ spinnerView: UIView?) {
        guard let spinnerView = spinnerView else { return }
        DispatchQueue.main.async {
            spinnerView.removeFromSuperview()
        }
    }
}
