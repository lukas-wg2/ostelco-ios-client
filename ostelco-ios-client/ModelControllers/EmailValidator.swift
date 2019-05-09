//
//  EmailValidator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 5/7/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class EmailValidator {
    var email: String? {
        didSet {
            self.validationState = self.validate()
        }
    }
    
    private(set) var validationState = ValidationState.notChecked
    
    let pleaseEnterAnythingErrorCopy = "Please enter an email address."
    let pleaseEnterValidErrorCopy = "Please enter a valid email address."
    
    private func validate() -> ValidationState {
        if self.validationState == .notChecked {
            guard (self.email?.count ?? 0) > 2 else {
                return .notChecked
            }
            // Keep going
        } // else, keep going.
        
        guard
            let email = self.email,
            email.isNotEmpty else {
                return .error(description: self.pleaseEnterAnythingErrorCopy)
        }
        
        // Some extremely basic email requirements:
        guard
            email.contains("@"), // must have an @ symbol
            !email.contains(" ") else { // can't have spaces
                return .error(description: self.pleaseEnterValidErrorCopy)
        }
        
        return .valid
    }
}
