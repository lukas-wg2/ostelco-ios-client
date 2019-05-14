//
//  SimProfileRequest.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct SimProfileRequest: Codable {
    public let profileType: String
    
    public init() {
        self.profileType = "iphone"
    }
    
    public enum CodingKeys: String, CodingKey {
        case profileType
    }
    
    public var asQueryItems: [URLQueryItem] {
        return [
            URLQueryItem(codingKey: CodingKeys.profileType, value: self.profileType)
        ]
    }
}
