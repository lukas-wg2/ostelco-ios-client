/*
 * Copyright 2019 Google
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCNUserDefaultsManager : NSObject

/// The last eTag received from the backend.
@property(nonatomic, assign) NSString *lastETag;
/// The time of the last successful fetch.
@property(nonatomic, assign) NSTimeInterval lastFetchTime;
/// The time of the last successful fetch.
@property(nonatomic, assign) NSString *lastFetchStatus;
/// Boolean indicating if the last (one or more) fetch(es) was/were unsuccessful, in which case we
/// are in an exponential backoff mode.
@property(nonatomic, assign) BOOL isClientThrottledWithExponentialBackoff;
/// Time when the next request can be made while being throttled.
@property(nonatomic, assign) NSTimeInterval throttleEndTime;
/// The retry interval increases exponentially for cumulative fetch failures. Refer to
/// go/rc-client-throttling for details.
@property(nonatomic, assign) NSTimeInterval currentThrottlingRetryIntervalSeconds;

/// Designated initializer.
- (instancetype)initWithAppName:(NSString *)appName
                       bundleID:(NSString *)bundleIdentifier
                      namespace:(NSString *)firebaseNamespace NS_DESIGNATED_INITIALIZER;

// NOLINTBEGIN
/// Use `initWithAppName:bundleID:namespace:` instead.
- (instancetype)init
    __attribute__((unavailable("Use `initWithAppName:bundleID:namespace:` instead.")));
// NOLINTEND

@end

NS_ASSUME_NONNULL_END
