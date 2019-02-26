//
//  Environment.swift
//  ostelco-ios-client
//
//  Created by mac on 10/30/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

public enum PlistKey {
    case ServerURL
    case StripePublishableKey
    case Auth0ClientID
    case Auth0Domain
    case Auth0LogoURL
    case FreshchatAppID
    case FreshchatAppKey
    case AppleMerchantId
    case BugseeToken
    
    func value() -> String {
        switch self {
        case .ServerURL:
            return "server_url"
        case .StripePublishableKey:
            return "stripe_publishable_key"
        case .Auth0ClientID:
            return "auth0_client_id"
        case .Auth0Domain:
            return "auth0_domain"
        case .Auth0LogoURL:
            return "auth0_logo_url"
        case .FreshchatAppID:
            return "freshchat_app_id"
        case .FreshchatAppKey:
            return "freshchat_app_key"
        case .AppleMerchantId:
            return "apple_merchant_id"
        case .BugseeToken:
            return "bugsee_token"
        }
    }
}

public struct Environment {
    
    fileprivate var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            }else {
                fatalError("Plist file not found")
            }
        }
    }
    public func configuration(_ key: PlistKey) -> String {
        var dictKey = ""
        switch key {
        case .ServerURL:
            dictKey = PlistKey.ServerURL.value()
            break;
        case .StripePublishableKey:
            dictKey = PlistKey.StripePublishableKey.value()
            break;
        case .Auth0ClientID:
            dictKey = PlistKey.Auth0ClientID.value()
            break;
        case .Auth0Domain:
            dictKey = PlistKey.Auth0Domain.value()
            break
        case .Auth0LogoURL:
            dictKey = PlistKey.Auth0LogoURL.value()
            break
        case .FreshchatAppID:
            dictKey = PlistKey.FreshchatAppID.value()
            break
        case .FreshchatAppKey:
            dictKey = PlistKey.FreshchatAppKey.value()
        case .AppleMerchantId:
            dictKey = PlistKey.AppleMerchantId.value()
            break
        case .BugseeToken:
            dictKey = PlistKey.BugseeToken.value()
            break
        }
        return (infoDict[dictKey] as! String).replacingOccurrences(of: "\\", with: "")
    }
}