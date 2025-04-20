//
//  TimeAttributes.swift
//  DynamicTime
//
//  Created by Alberto Paz on 19/4/25.
//

import ActivityKit
import SwiftUI

// Define the attributes for the Live Activity
struct TimeAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Add the dynamic time info that will update in the Live Activity
        var currentTime: TimeInterval
    }
    
    // No additional static information needed now that we always show seconds
}