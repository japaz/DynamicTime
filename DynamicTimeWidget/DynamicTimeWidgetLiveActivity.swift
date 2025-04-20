//
//  DynamicTimeWidgetLiveActivity.swift
//  DynamicTimeWidget
//
//  Created by Alberto Paz on 19/4/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

// We're using the TimeAttributes from our main app instead of this one
// The TimeAttributes is defined in the main app and shared with the widget

struct DynamicTimeWidgetLiveActivity: Widget {
    // Make sure this kind matches exactly what Xcode expects
    let kind: String = "DynamicTimeWidget"
    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimeAttributes.self) { context in
            // Lock screen/banner UI
            TimeActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.center) {
                    TimeActivityView(context: context)
                }
            } compactLeading: {
                // Compact leading UI - show seconds instead of hours/minutes
                Text(extractSeconds(from: context.state.currentTime))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            } compactTrailing: {
                // Compact trailing UI - just seconds
                Text(extractSeconds(from: context.state.currentTime))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            } minimal: {
                // Minimal UI (just the seconds)
                Text(extractSeconds(from: context.state.currentTime))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.red)
            }
        }
    }
    
    // Extract just the seconds part from a time interval
    private func extractSeconds(from timeInterval: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timeInterval)
        let second = Calendar.current.component(.second, from: date)
        return String(format: "%02d", second)
    }
}

// The main view for the Live Activity
struct TimeActivityView: View {
    let context: ActivityViewContext<TimeAttributes>
    
    var body: some View {
        let date = Date(timeIntervalSince1970: context.state.currentTime)
        let calendar = Calendar.current
        let second = calendar.component(.second, from: date)
        
        // ONLY show the seconds in large, bold red font
        Text(String(format: "%02d", second))
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding()
    }
}

// Preview for the Live Activity
#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: TimeAttributes()) {
    DynamicTimeWidgetLiveActivity()
} contentStates: {
    TimeAttributes.ContentState(currentTime: Date().timeIntervalSince1970)
}
