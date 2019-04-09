//
//  EnumHelperTests.swift
//  dev-ostelco-ios-clientTests
//
//  Created by Ellen Shapiro on 4/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

@testable import dev_ostelco_ios_client_app
import XCTest

class EnumHelperTests: XCTestCase {
    
    func testAllStoryboardsInEnumExist() {
        for storyboard in Storyboard.allCases {
            XCTAssertNoThrow(storyboard.asUIStoryboard)
        }
    }
}
