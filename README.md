# Dynamic Time App

A simple iOS app that displays the current time in the Dynamic Island when the app is in the background, using Live Activities.

## Features

- Displays the current time in the Dynamic Island when the app is in background
- Toggle between "seconds only" and "full time" (HH:MM:SS) display
- Minimal UI with just the necessary configuration options
- Targets iOS 16.1+ (compatible with iPhone 14 Pro and newer devices with Dynamic Island)

## Prerequisites

- macOS with latest Xcode installed
- iOS device with Dynamic Island (iPhone 14 Pro or newer) for testing
- Apple Developer account (free account works for development/testing)

## Setup Instructions

### Opening the Project in Xcode

1. Launch Xcode
2. Select "Open a project or file"
3. Navigate to the DynamicTime folder and open it

### Configuration

The project needs to be properly configured in Xcode:

1. Select the project in the Project Navigator
2. Under the "Signing & Capabilities" tab:
   - Add your development team
   - Enable "Live Activities" capability
   - Set the Bundle Identifier to a unique identifier

### Building and Running

1. Select your device as the run destination
2. Build and run the app (⌘R)
3. Grant required permissions if prompted
4. Use the toggle to select your preferred display format
5. Tap "Start Live Activity" to activate the Dynamic Island time display
6. Put the app in the background to see the Live Activity in action

## Technical Implementation

- **ActivityKit**: Used for Live Activities integration
- **SwiftUI**: For building the user interface
- **WidgetKit**: For implementing the Dynamic Island functionality
- **Timer**: Used to update the time every second

## Battery Usage Considerations

The app updates every second to keep the time accurate, which may impact battery life. The Live Activity system is designed to be efficient, but frequent updates will consume battery power.

## Termination

The Live Activity will automatically end after 8 hours (iOS restriction) or when the user taps "Stop Live Activity" in the app.

## App Store Submission

For App Store submission, additional requirements include:

- App icons
- Privacy policy
- App Store screenshots
- Proper app review information