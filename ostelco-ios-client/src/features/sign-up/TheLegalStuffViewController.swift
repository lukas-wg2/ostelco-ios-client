//
//  TheLegalStuffViewController.swift
//  ostelco-ios-client
//
//  Created by mac on 2/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class TheLegalStuffViewController: UIViewController {

    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    @IBOutlet weak var privacyPolicyLabel: UILabel!
    @IBOutlet weak var oyaUpdatesLabel: UILabel!

    @IBOutlet weak var termsAndConditionsSwitch: UISwitch!
    @IBOutlet weak var privacyPolicySwitch: UISwitch!
    @IBOutlet weak var oyaUpdatesSwitch: UISwitch!

    @IBOutlet weak var continueButton: UIButton!

    @IBAction func termsAndConditionsToggled(_ sender: Any) {
        toggleContinueButton()
    }

    @IBAction func privacyPolicyToggled(_ sender: Any) {
        toggleContinueButton()
    }

    @IBAction func oyaUpdatesToggled(_ sender: Any) {
        toggleContinueButton()
    }

    private func toggleContinueButton() {

        if termsAndConditionsSwitch.isOn && privacyPolicySwitch.isOn && oyaUpdatesSwitch.isOn {
            continueButton.isEnabled = true
            continueButton.backgroundColor = ThemeManager.currentTheme().mainColor
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = ThemeManager.currentTheme().mainColor.withAlphaComponent(CGFloat(0.15))
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let attributedString = NSMutableAttributedString(string: "I hereby agree to the Terms & Conditions", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0, weight: .bold), range: NSRange(location: 22, length: 18))
        termsAndConditionsLabel.attributedText = attributedString
        termsAndConditionsLabel.isUserInteractionEnabled = true
        let termsAndConditionsTapHandler = UITapGestureRecognizer(target: self, action: #selector(termsAndConditionsTapped))
        termsAndConditionsLabel.addGestureRecognizer(termsAndConditionsTapHandler)
        
        let attributedString2 = NSMutableAttributedString(string: "I agree to the  Privacy Policy", attributes: [
            .font: UIFont.systemFont(ofSize: 16.0, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16.0, weight: .bold), range: NSRange(location: 16, length: 14))
        privacyPolicyLabel.attributedText = attributedString2
        privacyPolicyLabel.isUserInteractionEnabled = true
        let privacyPolicyTapHandler = UITapGestureRecognizer(target: self, action: #selector(privacyPolicyTapped))
        privacyPolicyLabel.addGestureRecognizer(privacyPolicyTapHandler)
        
        let attributedString3 = NSMutableAttributedString(string: "I agree to recieve OYA updates by email. This consent can be revoked at any time.", attributes: [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor(white: 50.0 / 255.0, alpha: 1.0)
            ])
        oyaUpdatesLabel.attributedText = attributedString3

        toggleContinueButton()
    }

    @objc func termsAndConditionsTapped(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Open terms and conditions", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc func privacyPolicyTapped(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Open privacy policy", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
