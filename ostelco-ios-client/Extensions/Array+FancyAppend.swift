//
//  Array+FancyAppend.swift
//  ostelco-ios-client
//
//  Created by Ellen Shapiro on 4/17/19.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public extension Array {
    
    /// Checks if an object is non-nil, and then executes a closure that generates an Element and adds
    /// the result of that closure to the array if it exists, and no-ops if it doesn't.
    ///
    /// - Parameters:
    ///   - object: The object to validate needs to be appended.
    ///   - closure: The closure to execute if the object is non-nil.
    ///              Parameter will be the unrwapped object,
    ///              Returns an element constructed with the unwrapped object.
    mutating func appendIfNotNil<T>(_ object: T?, string closure: @escaping (T) -> Element) {
        guard let unwrapped = object else {
            return
        }
        
        self.append(closure(unwrapped))
    }
}

public extension Array where Element: Collection {
    
    /// Checks if the passed in element conforming to `Collection` is empty. Discards the element if it's empty, appends it if it's not.
    ///
    /// - Parameter element: The element to optionally append.
    mutating func appendIfNotEmpty(_ element: Element) {
        guard element.isNotEmpty else {
            return
        }
        
        self.append(element)
    }
}
