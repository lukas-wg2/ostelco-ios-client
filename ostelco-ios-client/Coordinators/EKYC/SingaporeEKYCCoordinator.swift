//
//  SingaporeEKYCCoordinator.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 6/4/19.
//  Copyright © 2019 mac. All rights reserved.
//

import ostelco_core
import UIKit

class SingaporeEKYCCoordinator: EKYCCoordinator {
    enum Destination {
        case goBackAndChooseCountry
        case landing
        case selectVerificationMethod
        case jumio
        case singPass
        case editSingPassAddress(address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate)
        case verifySingPassAddress(queryItems: [URLQueryItem])
        case enterAddress
        case stepsForNRIC
        case enterNRIC
        case ekycRejected
        case success(region: RegionResponse)
        case waitingForVerification
    }
    
    let navigationController: UINavigationController
    
    weak var delegate: EKYCCoordinatorDelegate?
    var jumioCoordinator: JumioCoordinator?
    var singPassCoordinator: SingPassCoordinator?
    let country = Country("sg")
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func determineDestination(from region: RegionResponse) -> SingaporeEKYCCoordinator.Destination {
            switch region.status {
            case .APPROVED:
                return .success(region: region)
            case .REJECTED:
                return .ekycRejected
            case .PENDING:
            guard
                let jumio = region.kycStatusMap.JUMIO,
                let addressAndPhoneNumber = region.kycStatusMap.ADDRESS_AND_PHONE_NUMBER,
                let nricFin = region.kycStatusMap.NRIC_FIN else {
                    return .goBackAndChooseCountry
            }
            
            switch (jumio, addressAndPhoneNumber, nricFin) {
            case (.PENDING, .PENDING, .PENDING):
                // User hasn't selected anything yet
                return .selectVerificationMethod
            case (.APPROVED, .APPROVED, .APPROVED):
                // This probably should have shown as a success at a higher level, but ¯\_(ツ)_/¯
                return .success(region: region)
            case (.REJECTED, _, _):
                // If jumio is rejected, *everything* is rejected.
                return .ekycRejected
            case (.PENDING, .APPROVED, .APPROVED):
                // The user only used NRIC + Address, we're good.
                return .success(region: region)
            case (.PENDING, .PENDING, .APPROVED):
                // The user has an approved NRIC but we need an address
                return .enterAddress
            default:
                return .goBackAndChooseCountry
            }
        }
    }
    
    func navigate(to destination: SingaporeEKYCCoordinator.Destination, animated: Bool) {
        switch destination {
        case .stepsForNRIC:
            let stepsVC = ScanICStepsViewController.fromStoryboard()
            stepsVC.coordinator = self
            self.navigationController.pushViewController(stepsVC, animated: true)
        case .enterAddress:
            let addressEdit = AddressEditViewController.fromStoryboard()
            addressEdit.mode = .nricEdit
            addressEdit.coordinator = self
            self.navigationController.setViewControllers([addressEdit], animated: animated)
        case .editSingPassAddress(let address, let delegate):
            let addressEdit = AddressEditViewController.fromStoryboard()
            addressEdit.mode = .myInfoVerify(myInfo: address)
            addressEdit.myInfoDelegate = delegate
            self.navigationController.pushViewController(addressEdit, animated: animated)
        case .selectVerificationMethod:
            let selectVerificationMethodVC = SelectIdentityVerificationMethodViewController.fromStoryboard()
            self.navigationController.pushViewController(selectVerificationMethodVC, animated: animated)
        case .ekycRejected:
            self.showEKYCRejectedPage(animated: animated)
        case .goBackAndChooseCountry:
            self.delegate?.reselectCountry()
        case .success(let region):
            self.delegate?.ekycSuccessful(region: region)
        case .landing:
            self.showEKYCLandingPage(animated: animated)
        case .jumio:
            self.launchJumio(animated: animated)
        case .enterNRIC:
            let nricVC = NRICVerifyViewController.fromStoryboard()
           nricVC.coordinator = self
            self.navigationController.pushViewController(nricVC, animated: animated)
        case .singPass:
            let singPassCoordinator = SingPassCoordinator()
            singPassCoordinator.delegate = self
            singPassCoordinator.startLogin(from: self.navigationController)
            self.singPassCoordinator = singPassCoordinator
        case .verifySingPassAddress(let queryItems):
            let myInfoSummary = MyInfoSummaryViewController.fromStoryboard()
            myInfoSummary.myInfoQueryItems = queryItems
            self.navigationController.setViewControllers([myInfoSummary], animated: animated)
        case .waitingForVerification:
            self.showWaitingForVerification(animated: animated)
        }
    }
    
    func ekycRejectedRetryHandler() {
        // Let the user reselect a validation method
        self.navigate(to: .selectVerificationMethod, animated: true)
    }
    
    func showFirstStepAfterLanding() {
        self.navigate(to: .selectVerificationMethod, animated: true)
    }
    
    func selectedSingPass() {
        self.navigate(to: .singPass, animated: true)
    }
    
    func selectedNRIC() {
        self.navigate(to: .stepsForNRIC, animated: true)
    }
    
    func wantsToEnterNRIC() {
        self.navigate(to: .enterNRIC, animated: true)
    }
    
    func enteredNRICSuccessfully() {
        self.navigate(to: .enterAddress, animated: true)
    }
    
    func editSingPassAddress(_ address: MyInfoAddress?, delegate: MyInfoAddressUpdateDelegate) {
        self.navigate(to: .editSingPassAddress(address: address, delegate: delegate), animated: true)
    }
    
    private func updateRegionAndNavigate(animated: Bool) {
        APIManager.shared.primeAPI
            .loadRegion(code: self.country.countryCode)
            .done { region in
                let destination = self.determineDestination(from: region)
                self.navigate(to: destination, animated: animated)
            }
            .catch { error in
                ApplicationErrors.log(error)
            }
    }
    
    func verifiedSingPassAddress() {
        self.updateRegionAndNavigate(animated: true)
    }
    
    func enteredAddressSuccessfully() {
        
    }
}

extension SingaporeEKYCCoordinator: JumioCoordinatorDelegate {
    
    func completedJumioSuccessfully(scanID: String) {
        self.navigate(to: .enterAddress, animated: true)
    }
    
    func jumioScanFailed(errorMessage: String) {
        self.handleError(message: errorMessage)
    }
}

extension SingaporeEKYCCoordinator: SingPassCoordinatorDelegate {
    
    func signInSucceeded(myInfoQueryItems: [URLQueryItem]) {
        self.navigate(to: .verifySingPassAddress(queryItems: myInfoQueryItems), animated: true)
    }
    
    func signInFailed(error: NSError?) {
        // TODO: This wasn't handled before, do we need to do anything here?
        debugPrint("Error: \(String(describing: error))")
    }
}