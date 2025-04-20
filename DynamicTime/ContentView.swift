//
//  ContentView.swift
//  DynamicTime
//
//  Created by Alberto Paz on 19/4/25.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @State private var isActivityRunning = false
    @State private var currentActivity: Activity<TimeAttributes>? = nil
    @State private var statusMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Dynamic Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Always showing seconds")
                    .font(.headline)
                    .padding()
                
                if !statusMessage.isEmpty {
                    Text(statusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    if isActivityRunning {
                        stopLiveActivity()
                    } else {
                        startLiveActivity()
                    }
                }) {
                    Text(isActivityRunning ? "Stop Live Activity" : "Start Live Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isActivityRunning ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
    
    private func startLiveActivity() {
        // Create the activity attributes
        let attributes = TimeAttributes()
        
        // Create the initial content state
        let initialContentState = TimeAttributes.ContentState(
            currentTime: Date().timeIntervalSince1970
        )
        
        // Start the activity - using the non-deprecated API
        do {
            // Check if we're running in a simulator
            #if targetEnvironment(simulator)
            // Simulator workaround for eligibility.plist error
            if !ActivityAuthorizationInfo().areActivitiesEnabled {
                print("Live Activities not enabled - this is expected in Simulator")
                // Still setting the state so UI behaves as if activity started
                isActivityRunning = true
                statusMessage = "Live Activities not enabled - this is expected in Simulator"
                
                // Schedule simulated updates even without a real activity
                scheduleTimeUpdates()
                return
            }
            #endif
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: initialContentState, staleDate: nil),
                pushType: nil
            )
            currentActivity = activity
            isActivityRunning = true
            statusMessage = "Started time activity with id: \(activity.id)"
            
            // Schedule updates for the Live Activity
            scheduleTimeUpdates()
            
            print("Started time activity with id: \(activity.id)")
        } catch {
            print("Error starting time activity: \(error.localizedDescription)")
            statusMessage = "Error starting time activity: \(error.localizedDescription)"
        }
    }
    
    private func stopLiveActivity() {
        // Use 'await' with Task.init when we don't care about the result
        Task {
            if let activity = currentActivity {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("Ended time activity with id: \(activity.id)")
                statusMessage = "Ended time activity with id: \(activity.id)"
            }
            
            isActivityRunning = false
            currentActivity = nil
        }
    }
    
    private func scheduleTimeUpdates() {
        // Calculate the time until the next whole second
        let now = Date()
        let calendar = Calendar.current
        let milliseconds = calendar.component(.nanosecond, from: now) / 1_000_000
        let timeToNextSecond = 1000 - milliseconds
        
        // Schedule the first update to happen exactly at the next second boundary
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(timeToNextSecond))) {
            // This will execute right at the second boundary
            // Using @MainActor to properly handle the async Task
            @MainActor func updateLiveActivity() async {
                if let activity = self.currentActivity {
                    let updatedContentState = TimeAttributes.ContentState(
                        currentTime: Date().timeIntervalSince1970
                    )
                    
                    await activity.update(ActivityContent(state: updatedContentState, staleDate: nil))
                }
                
                // Only continue with the timer if the activity is still running
                if self.isActivityRunning {
                    // Now set up a precise timer that fires exactly on second boundaries
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                        guard self.isActivityRunning else {
                            timer.invalidate()
                            return
                        }
                        
                        // Using Task with async/await properly
                        Task { @MainActor in
                            if let activity = self.currentActivity {
                                let updatedContentState = TimeAttributes.ContentState(
                                    currentTime: Date().timeIntervalSince1970
                                )
                                
                                await activity.update(ActivityContent(state: updatedContentState, staleDate: nil))
                            } else {
                                // If we don't have an activity (simulator case), just update UI state
                                #if targetEnvironment(simulator)
                                // This is a no-op since we're just simulating in the simulator
                                #endif
                            }
                        }
                    }
                }
            }
            
            // Start the async function
            Task { @MainActor in
                await updateLiveActivity()
            }
        }
    }
}

#Preview {
    ContentView()
}
