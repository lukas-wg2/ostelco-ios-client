//
//  EdgeCasesInStageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/27/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class EdgeCasesInStageDeciderTests: XCTestCase {
    // Existing Singapore user who logs in to a new device but has completed the onboarding on a different device.
    
    let noRegions: [PrimeGQL.RegionDetailsFragment] = []
    
    func testUserSignsUpOnNewDeviceAfterCompletingOnboardingOnOtherDevice() {
        let decider = StageDecider()
        let localContext = OnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .APPROVED,
            simProfiles: [
                SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED)
            ],
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )
        let context = Context(customer: CustomerModel(id: "xx", name: "xxx", email: "xxx", analyticsId: "xxx", referralId: "xxx"), regions: [region])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .notificationPermissions)
    }
    
    func testUserSignsUpOnNewDeviceAndGivesNotificationPermissionsAfterCompletingOnboardingOnOtherDevice() {
        let decider = StageDecider()
        let localContext = OnboardingContext(hasFirebaseToken: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED)
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
    
    func testUserKillsAppAfterCompletingOnboardingSuccessfullyButBeforeAwesomeScreen() {
        let decider = StageDecider()
        let localContext = OnboardingContext(hasFirebaseToken: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxx", iccId: "xxx", status: .INSTALLED)
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }
    
    func testServerIsUnavailableOnStartUp() {
        let decider = StageDecider()
        let context: Context? = nil
        let localContext = OnboardingContext(serverIsUnreachable: true)
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .ohNo(.serverUnreachable))
    }
    
    // Edge cases for Singapore flow
    
    func testMyInfoSummaryLoadFailedandSelectedVerificationOptionIsResetToNil() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
        )

        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }

    func testUserHasCompletedNRICAndCancelledJumioInSingapore() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasCompletedJumioButGotRejected() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCompletedJumio: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .ohNo(.ekycRejected))
    }
    
    // Edge cases for Norway flow
    func testUserHasCompletedJumioButGotRejectedInNorway() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(hasCompletedJumio: true)
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .ohNo(.ekycRejected))
    }
    
    func testUserIsRejectedInNorwayForJumioButWantsToTryAgain() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "no", name: "Norway"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .jumio)
    }
    
    func testUserIsRejectedInSingaporeForJumioButWantsToTryAgain() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext()
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: .REJECTED, myInfo: .PENDING, nricFin: .PENDING, addressPhone: .PENDING)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testShowCameraProblemBeforeJumioWhenSelectingScanICInSingaporeIfThereIsACameraProblem() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .scanIC, hasCameraProblem: true)
        let region = RegionResponse(
            region: Region(id: "sg", name: "Singapore"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap()
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .cameraProblem)
    }
    
    func testShowCameraProblemAfterVerifyIdentityOnboardingInNorwayIfThereIsACameraProblem() {
        let decider = StageDecider()
        let localContext = RegionOnboardingContext(selectedVerificationOption: .jumio, hasCameraProblem: true)
        let region = RegionResponse(
            region: Region(id: "no", name: "NO"),
            status: .PENDING,
            simProfiles: nil,
            kycStatusMap: KYCStatusMap(jumio: nil, myInfo: nil, nricFin: nil, addressPhone: nil)
        )
        
        XCTAssertEqual(decider.stageForRegion(region: region, localContext: localContext), .cameraProblem)
    }
    
    func testExistingUserLogsIn() {
        let decider = StageDecider()
        let localContext = OnboardingContext(hasFirebaseToken: true)
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "no", name: "Norway"),
                    status: .APPROVED,
                    simProfiles: [
                        SimProfile(eSimActivationCode: "xxx", alias: "xxxx", iccId: "xxxx", status: .INSTALLED)
                    ],
                    kycStatusMap: KYCStatusMap(jumio: .APPROVED, myInfo: .PENDING, nricFin: .APPROVED, addressPhone: .APPROVED)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .home)
    }

}
