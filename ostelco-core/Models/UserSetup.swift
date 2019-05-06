//
//  UserSetup.swift
//  ostelco-core
//
//  Created by Ellen Shapiro on 5/6/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public struct UserSetup: Codable {
    let nickname: String
    let contactEmail: String
    
    public init(nickname: String,
                email: String) {
        self.nickname = nickname
        self.contactEmail = email
    }
}
