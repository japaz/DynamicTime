import Foundation
import ActivityKit

class LiveActivityTimerManager: ObservableObject {
    @Published var isActivityRunning = false
    @Published var statusMessage = ""
    @Published var currentActivity: Activity<TimeAttributes>? = nil
    private var timer: DispatchSourceTimer? = nil
    
    func startLiveActivity() {
        let attributes = TimeAttributes()
        let initialContentState = TimeAttributes.ContentState(
            currentTime: Date().timeIntervalSince1970
        )
        do {
            #if targetEnvironment(simulator)
            if !ActivityAuthorizationInfo().areActivitiesEnabled {
                print("Live Activities not enabled - this is expected in Simulator")
                isActivityRunning = true
                statusMessage = "Live Activities not enabled - this is expected in Simulator"
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
            scheduleTimeUpdates()
            print("Started time activity with id: \(activity.id)")
        } catch {
            print("Error starting time activity: \(error.localizedDescription)")
            statusMessage = "Error starting time activity: \(error.localizedDescription)"
        }
    }
    
    func stopLiveActivity() {
        Task {
            if let activity = currentActivity {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("Ended time activity with id: \(activity.id)")
                statusMessage = "Ended time activity with id: \(activity.id)"
            }
            isActivityRunning = false
            currentActivity = nil
            timer?.cancel()
            timer = nil
        }
    }
    
    private func scheduleTimeUpdates() {
        let now = Date()
        let calendar = Calendar.current
        let nextSecond = calendar.nextDate(after: now, matching: DateComponents(nanosecond: 0), matchingPolicy: .strict, direction: .forward) ?? now.addingTimeInterval(1)
        let delay = nextSecond.timeIntervalSinceNow
        // Invalidate any existing timer before creating a new one
        timer?.cancel()
        timer = nil
        print("[Timer] Creating new DispatchSourceTimer. Will fire in \(delay) seconds, then every 1.0s.")
        let newTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        newTimer.schedule(deadline: .now() + delay, repeating: 1.0)
        newTimer.setEventHandler { [weak self] in
            guard let self = self, self.isActivityRunning else {
                print("[Timer] Timer cancelled or activity stopped.")
                self?.timer?.cancel()
                self?.timer = nil
                return
            }
            Task { @MainActor in
                let logTime = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss.SSS"
                let formattedTime = formatter.string(from: logTime)
                if let activity = self.currentActivity {
                    print("Updating content for activity \(activity.id) at \(formattedTime)")
                    let updatedContentState = TimeAttributes.ContentState(
                        currentTime: Date().timeIntervalSince1970
                    )
                    await activity.update(ActivityContent(state: updatedContentState, staleDate: nil))
                } else {
                    #if targetEnvironment(simulator)
                    // This is a no-op since we're just simulating in the simulator
                    #endif
                }
            }
        }
        newTimer.resume()
        print("[Timer] Timer started and resumed.")
        timer = newTimer
    }
}
