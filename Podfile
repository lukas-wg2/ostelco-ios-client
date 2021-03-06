	# The minimum supported iOS version for your project
platform :ios, '12.1'

# Enable everything to be compiled into frameworks
use_frameworks!

# Don't show warnings from frameworks to prevent polluting warnings
inhibit_all_warnings!

def firebase_version
  # All Firebase libs should have the same version
  '~>6.10.0'
end

abstract_target 'ostelco-ios' do
  pod 'PromiseKit', '~> 6.8.4' # Promises for Swift
  pod "Apollo"
  pod 'Crashlytics', '~>3.13.1'
  pod 'Fabric', '~>1.10.0'
  pod 'FacebookCore'
  pod 'FreshchatSDK', '~>2.8.0' # Customer Support live chat
  pod 'Firebase/Auth', firebase_version
  pod 'Firebase/DynamicLinks', firebase_version
  pod 'Firebase/Messaging', firebase_version
  pod 'Firebase/Analytics', firebase_version
  pod 'Firebase/Performance', firebase_version
  pod 'Firebase/RemoteConfig', firebase_version
  pod 'JumioMobileSDK/Netverify', '~>3.3.1' # eKYC
  pod 'Stripe', '~>15.0.0' # Payments
  pod 'SwiftLint', '~>0.32.0'

  # Dev app target
  target 'dev-ostelco-ios-client' do

    # Test target
    target 'dev-ostelco-ios-clientTests' do
      inherit! :search_paths
      pod 'OHHTTPStubs/Swift', '~>8.0.0' # URL mocking
    end
  end

  # Prod app target
  target 'ostelco-ios-client' do
  end
end
