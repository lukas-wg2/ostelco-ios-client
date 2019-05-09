//
//  SourceInfo.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/8/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct PaymentInfo: Codable {
    public let sourceId: String
    
    public init(sourceID: String) {
        self.sourceId = sourceID
    }
}
