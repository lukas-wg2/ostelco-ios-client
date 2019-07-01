//
//  StageDeciderTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by mac on 6/26/19.
//  Copyright © 2019 mac. All rights reserved.
//

import XCTest
@testable import ostelco_core

class SingaporeUserHappyFlowWithSingPassStageDeciderTests: XCTestCase {
    // Testing the flow of a singapore user who uses singpass and has no trouble:
    
    func testColdStartForAUser() {
        let decider = StageDecider()
        
        XCTAssertEqual(decider.compute(context: nil, localContext: LocalContext()), .loginCarousel)
    }
    
    func testUserHasSeenLoginCarousel() {
        let decider = StageDecider()
        
        XCTAssertEqual(decider.compute(context: nil, localContext: LocalContext(hasSeenLoginCarousel: true)), .emailEntry)
    }
    
    func testUserHasEnteredEmail() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenLoginCarousel: true, enteredEmailAddress: "xxxx@xxxx.com")
        
        XCTAssertEqual(decider.compute(context: nil, localContext: localContext), .checkYourEmail(email: "xxxx@xxxx.com"))
    }
    
    func testUserHasAFirebaseUserButNoContextYet() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenLoginCarousel: true, enteredEmailAddress: "xxxx@xxxx.com", hasFirebaseToken: true)
        
        XCTAssertEqual(decider.compute(context: nil, localContext: localContext), .legalStuff)
    }
    
    func testUserHasAgreedToLegalStuff() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenLoginCarousel: true, enteredEmailAddress: "xxxx@xxxx.com", hasFirebaseToken: true, hasAgreedToTerms: true)
        
        XCTAssertEqual(decider.compute(context: nil, localContext: localContext), .notificationPermissions)
    }
    
    func testUserHasSeenNotificationPermissions() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenLoginCarousel: true, enteredEmailAddress: "xxxx@xxxx.com", hasFirebaseToken: true, hasAgreedToTerms: true, hasSeenNotificationPermissions: true)
        
        XCTAssertEqual(decider.compute(context: nil, localContext: localContext), .nicknameEntry)
    }
    
    func testUserHasEnteredNickname() {
        let decider = StageDecider()
        let localContext = LocalContext()
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectRegion)
    }
    
    func testUserHasSelectedACountry() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"))
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .locationPermissions)
    }
    
    func testUserHasSelectedACountryAndIsInThatCountry() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyIdentityOnboarding)
    }
    
    func testUserHasSeenVerifyIdentifyOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true)
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .selectIdentityVerificationMethod([.scanIC, .singpass]))
    }
    
    func testUserHasSelectedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.singpass)
        
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .singpass)
    }
    
    func testUserHasCompletedSingpass() {
        let decider = StageDecider()
        let localContext = LocalContext(selectedRegion: Region(id: "sg", name: "SG"), regionVerified: true, hasSeenVerifyIdentifyOnboarding: true, selectedVerificationOption: StageDecider.IdentityVerificationOption.singpass, myInfoCode: "xxx")
        
        let context = Context(customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"), regions: [])
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .verifyMyInfo(code: "xxx"))
    }
    
    func testUserHasCompletedSingpassAndVerifiedTheirAddress() {
        let decider = StageDecider()
        let localContext = LocalContext()
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimOnboarding)
    }
    
    func testUserHasSeenTheESimOnboarding() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenESimOnboarding: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .eSimInstructions)
    }
    
    func testUserHasSeenTheESimInstructions() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenESimOnboarding: true, hasSeenESIMInstructions: true)
        
        let context = Context(
            customer: CustomerModel(id: "xxx", name: "xxx", email: "xxxx@gmail.com", analyticsId: "xxxx", referralId: "xxxx"),
            regions: [
                RegionResponse(
                    region: Region(id: "sg", name: "Singapore"),
                    status: .APPROVED,
                    simProfiles: nil,
                    kycStatusMap: KYCStatusMap(jumio: .PENDING, myInfo: .APPROVED, nricFin: .PENDING, addressPhone: .PENDING)
                )
            ]
        )
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .pendingESIMInstall)
    }
    
    func testUserHasInstalledESIM() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenESimOnboarding: true, hasSeenESIMInstructions: true)
        
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
        
        XCTAssertEqual(decider.compute(context: context, localContext: localContext), .awesome)
    }
    
    func testUserHasInstalledESIMAndSeenAwesome() {
        let decider = StageDecider()
        let localContext = LocalContext(hasSeenESimOnboarding: true, hasSeenESIMInstructions: true, hasSeenAwesome: true)
        
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
}
