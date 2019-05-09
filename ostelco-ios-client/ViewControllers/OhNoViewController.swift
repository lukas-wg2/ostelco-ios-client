//
//  OhNoViewController.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/25/19.
//  Copyright © 2019 mac. All rights reserved.
//

import OstelcoStyles
import UIKit

/// A view controller for handling errors
class OhNoViewController: UIViewController {
    
    enum IssueType {
        case generic(code: String?)
        case ekycRejected
        case myInfoFailed
        
        var displayTitle: String {
            switch self {
            case .generic,
                 .ekycRejected,
                 .myInfoFailed:
                return "Oh no"
            }
        }
        
        var displayImage: UIImage {
            switch self {
            case .generic,
                 .myInfoFailed:
                return UIImage(named: "illustrationGhost")!
            case .ekycRejected:
                return UIImage(named: "illustrationPainter")!
            }
        }
        
        var issueDescription: NSAttributedString {
            switch self {
            case .generic(let code):
                let attributedString = NSMutableAttributedString(string: "Something went wrong. Try again in a while.")
                guard let errorCode = code else {
                    return attributedString
                }
                
                attributedString.append(NSAttributedString(string: "If you contact customer support, please use this error code: "))
                attributedString.append(NSAttributedString(string: errorCode, attributes: [
                    .font: OstelcoFont(fontType: .bold, fontSize: .body).toUIFont
                ]))
                
                return NSAttributedString(attributedString: attributedString)
            case .ekycRejected:
                return NSAttributedString(string: "Something went wrong.\n\nTry again in a while, or contact support")
            case .myInfoFailed:
                return NSAttributedString(string: "We're unable to retrieve your info from MyInfo.\n\n. Try later.")
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .generic,
                 .myInfoFailed:
                return "Try again"
            case .ekycRejected:
                return "Retry"
            }
        }
    }
    
    @IBOutlet private var primaryButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    /// Convenience method for loading and populating with values for a given type
    ///
    /// - Parameter type: The type to use to configure copy and image
    /// - Returns: The instantiated and configured VC.
    static func fromStoryboard(type: IssueType) -> OhNoViewController {
        let vc = self.fromStoryboard()
        vc.displayTitle = type.displayTitle
        vc.displayImage = type.displayImage
        vc.buttonTitle = type.buttonTitle
        vc.issueDescription = type.issueDescription
        
        return vc
    }
    
    /// The title at the top of the screen
    var displayTitle: String = "Oh no" {
        didSet {
            self.configureTitle()
        }
    }
    
    /// The text displayed on the button
    var buttonTitle: String = "Try again" {
        didSet {
            self.configurePrimaryButton()
        }
    }
    
    /// The description of whatever went wrong. Attributed so parts can be highlighted if needed.
    var issueDescription: NSAttributedString = NSAttributedString(string: "Something went wrong.\n\nTry again in a while, or contact support") {
        didSet {
            self.configureDescription()
        }
    }
    
    /// The image to use to entertain the user while explaining something went wrong.
    var displayImage: UIImage = UIImage(named: "illustrationGhost")! {
        didSet {
            self.configureImage()
        }
    }
    
    /// The action to take when the user taps the primary button.
    var primaryButtonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configurePrimaryButton()
        self.configureDescription()
        self.configureTitle()
        self.configureImage()
    }
    
    private func configureDescription() {
        self.descriptionLabel?.attributedText = self.issueDescription
    }
    
    private func configureTitle() {
        self.titleLabel?.text = self.displayTitle
    }
    
    private func configurePrimaryButton() {
        self.primaryButton?.setTitle(self.buttonTitle, for: .normal)
    }
    
    private func configureImage() {
        self.imageView?.image = self.displayImage
    }
    
    @IBAction private func needHelpTapped() {
        self.showNeedHelpActionSheet()
    }
    
    @IBAction private func primaryButtonTapped() {
        guard let action = self.primaryButtonAction else {
            assertionFailure("You probably want to do something here!")
            return
        }
        
        action()
    }
}

extension OhNoViewController: StoryboardLoadable {
    
    static var isInitialViewController: Bool {
        return true
    }
    
    static var storyboard: Storyboard {
        return .ohNo
    }
}