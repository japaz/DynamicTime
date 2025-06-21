//
//  ContentView.swift
//  DynamicTime
//
//  Created by Alberto Paz on 19/4/25.
//

import SwiftUI
import ActivityKit

struct ContentView: View {
    @StateObject private var timerManager = LiveActivityTimerManager()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Text("Dynamic Time")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Always showing seconds")
                    .font(.headline)
                    .padding()
                
                if !timerManager.statusMessage.isEmpty {
                    Text(timerManager.statusMessage)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    if timerManager.isActivityRunning {
                        timerManager.stopLiveActivity()
                    } else {
                        timerManager.startLiveActivity()
                    }
                }) {
                    Text(timerManager.isActivityRunning ? "Stop Live Activity" : "Start Live Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(timerManager.isActivityRunning ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    ContentView()
}
