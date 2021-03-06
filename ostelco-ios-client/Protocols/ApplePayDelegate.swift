//
//  ApplePayDelegate.swift
//  ostelco-ios-client
//
//  Created by Prasanth Ullattil on 28/04/2019.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import PromiseKit
import Stripe

enum ApplePayError: Error {
    // Apple pay support related Errors
    case unsupportedDevice
    case noSupportedCards
    case otherRestrictions
    // Other errors during payment
    case userCancelled
    case paymentDeclined
    case primeAPIError(Error)
    case invalidConfiguration
}

extension ApplePayError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unsupportedDevice:
            return "Your device does not support apple pay"
        case .noSupportedCards:
            return "You need to setup a card in your wallet, we support the following cards: American Express, Visa, Mastercard, Discover"
        case .otherRestrictions:
            return "Your device has some restrictions preventing payment (such as parental controls)"
        // Other errors during payment
        case .userCancelled:
            return "User has cancelled the payment"
        case .paymentDeclined:
            return "Payment was declined"
        case .primeAPIError:
            return "Prime API Error"
        case .invalidConfiguration:
            return "There is a problem with your Apple Pay configuration even though Apple pay is supposed to work. Don't know why it failed."
        }
    }
}

protocol ApplePayDelegate: class {
    var shownApplePay: Bool { get set }
    var authorizedApplePay: Bool { get set }
    var purchasingProduct: Product? { get set }
    var applePayError: ApplePayError? { get set }

    func paymentError(_ error: Error)
    func paymentSuccessful(_ product: Product?)

    func handlePaymentAuthorized(_ controller: PKPaymentAuthorizationViewController,
                                 didAuthorizePayment payment: PKPayment,
                                 handler completion: @escaping (PKPaymentAuthorizationResult) -> Void)
    func handlePaymentFinished(_ controller: PKPaymentAuthorizationViewController)
}

extension ApplePayDelegate where Self: PKPaymentAuthorizationViewControllerDelegate & UIViewController {
    // MARK: - Default implementaion of PKPaymentAuthorizationViewControllerDelegate.

    // TODO
    func handlePaymentAuthorized(_ controller: PKPaymentAuthorizationViewController,
                                 didAuthorizePayment payment: PKPayment,
                                 handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        authorizedApplePay = true
        let product = purchasingProduct!
        
        // Create Stripe Source.
        STPAPIClient.shared().promiseCreateSource(with: payment)
            .then { source -> Promise<Void> in
                // Call Prime API to buy the product.
                let payment = PaymentInfo(sourceID: source.stripeID)
                return APIManager.shared.primeAPI.purchaseProduct(with: product.sku, payment: payment)
            }
            .done {
                debugPrint("Successfully bought product \(product.sku)")
                completion(PKPaymentAuthorizationResult(status: .success, errors: []))
            }
            .catch { error in
                debugPrint("Failed to buy product with sku %{public}@, got error: %{public}@", "123", "\(error)")
                ApplicationErrors.log(error)
                self.applePayError = self.createPaymentError(error)
                completion(PKPaymentAuthorizationResult(status: .failure, errors: [error]))
                // Wait for finish method before we call paymentError()
            }
    }

    // TODO
    func handlePaymentFinished(_ controller: PKPaymentAuthorizationViewController) {
        // Dismiss payment authorization view controller
        dismiss(animated: true, completion: {
            if let applePayError = self.applePayError {
                self.paymentError(applePayError)
            } else if self.authorizedApplePay {
                self.paymentSuccessful(self.purchasingProduct)
            } else {
                self.paymentError(ApplePayError.userCancelled)
            }
        })
    }

    // MARK: - Helpers for starting Apple Pay.

    func startApplePay(product: Product) {
        OstelcoAnalytics.logEvent(.addToCart(name: product.name, sku: product.sku, countryCode: product.country, amount: product.stripeAmount, currency: product.currency))
        shownApplePay = false
        authorizedApplePay = false
        purchasingProduct = product
        applePayError = nil
        let merchantIdentifier = EnvironmentPlist().configuration(.AppleMerchantId)
        // TODO: Consult with Payment Service Provider (Stripe in our case) to determine which country code value to use
        // https://developer.apple.com/documentation/passkit/pkpaymentrequest/1619246-countrycode
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantIdentifier, country: product.country, currency: product.currency)
        if let applePayError = canMakePayments() {
            paymentError(applePayError)
            return
        }
        // Convert to acutal amount (prime uses currency’s smallest unit)
        let applePayAmount = product.stripeAmount
        let tax = product.stripeTax
        let subTotal = product.stripeSubTotal
        // Configure the line items on the payment request
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: product.subTotalLabel, amount: subTotal),
            PKPaymentSummaryItem(label: product.taxLabel, amount: tax),
            PKPaymentSummaryItem(label: product.payeeLabel, amount: applePayAmount),
        ]
        if Stripe.canSubmitPaymentRequest(paymentRequest) {
            // Setup payment authorization view controller
            let paymentAuthorizationViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest)
            paymentAuthorizationViewController!.delegate = self
            // Present payment authorization view controller
            shownApplePay = true
            present(paymentAuthorizationViewController!, animated: true)
        } else {
            // There is a problem with your Apple Pay configuration
            debugPrint("There is a problem with your Apple Pay configuration, we should have caught this before...")
            // TODO: Report error to bug reporting system
            self.showAlert(title: "There is a problem with your Apple Pay configuration", msg: "Apple pay is supposed to work. Don't know why it failed.")
        }
    }

    // MARK: - Other Helpers.

    // Create appropriate ApplePayError based on the Error
    func createPaymentError(_ error: Error) -> ApplePayError {
        switch error {
        case APIHelper.Error.jsonError(let jsonError):
            // Handle status logic here, return payment declined if needed otherwise keep going
            // Payment is declined when status = 403 and code = FAILED_TO_PURCHASE_PRODUCT
            if jsonError.httpStatusCode == 403 && jsonError.errorCode == "FAILED_TO_PURCHASE_PRODUCT" {
                return ApplePayError.paymentDeclined
            }
        default:
            break
        }
        // All generic payment errors are treated as primeAPIError
        return ApplePayError.primeAPIError(error)
    }

    // Findout if we can make payments on this device.
    func canMakePayments() -> ApplePayError? {
        let deviceAllowed = PKPaymentAuthorizationViewController.canMakePayments()
        let cardNetworks: [PKPaymentNetwork] = [.amex, .visa, .masterCard]
        let cardsAllowed = PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: cardNetworks)
        let stripeAllowed = Stripe.deviceSupportsApplePay()
        switch (deviceAllowed, cardsAllowed, stripeAllowed) {
        case (true, true, false):
            return ApplePayError.otherRestrictions
        case (true, false, _):
            return ApplePayError.noSupportedCards
        case (false, _, _):
            return ApplePayError.unsupportedDevice
        case (true, true, true):
            return nil
        }
    }

    // Stripe (& Prime) expects amounts to be provided in currency's smallest unit.
    // https://stripe.com/docs/currencies#zero-decimal
    // https://github.com/stripe/stripe-ios/blob/v15.0.1/Stripe/NSDecimalNumber%2BStripe_Currency.m
    func convertStripeToNormalCurrency(amount: Decimal, currency: String) -> NSDecimalNumber {
        let zeroDecimalCountries = [
            "bif", "clp", "djf", "gnf", "jpy",
            "kmf", "krw", "mga", "pyg", "rwf",
            "vnd", "vuv", "xaf", "xof", "xpf"
        ]
        let amountInCurrency = NSDecimalNumber(decimal: amount)
        if zeroDecimalCountries.contains(currency.lowercased()) {
            return amountInCurrency
        } else {
            return amountInCurrency.multiplying(byPowerOf10: -2)
        }
    }
}
