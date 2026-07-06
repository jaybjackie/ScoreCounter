//
//  ContentView.swift
//  ScoreCounter Watch App
//
//  Created by jaybjackie on 6/7/2569 BE.
//

import SwiftUI

@Observable
final class SideState {
    var score = 0
    var isPressing = false
    var longPressTriggered = false
    var resetReady = false
}

struct ContentView: View {
    @State private var red = SideState()
    @State private var blue = SideState()
    @State private var showResetText = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                scoreSide(state: red, color: .red)
                scoreSide(state: blue, color: .blue)
            }
            .ignoresSafeArea()

            if showResetText {
                Text("Reset")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
    }

    private func scoreSide(state: SideState, color: Color) -> some View {
        Text("\(state.score)")
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .scaleEffect(state.isPressing ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: state.isPressing)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(color)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard !state.isPressing else { return }
                        state.isPressing = true
                        state.longPressTriggered = false
                        startLongPressTimer(state: state)
                    }
                    .onEnded { _ in
                        state.isPressing = false
                        if !state.longPressTriggered {
                            state.score += 1
                        }
                        state.longPressTriggered = false
                    }
            )
    }

    private func startLongPressTimer(state: SideState) {
        Task {
            try? await Task.sleep(for: .seconds(1))
            guard state.isPressing else { return }
            state.longPressTriggered = true
            state.resetReady = true
            checkReset()
        }
    }

    private func checkReset() {
        guard red.resetReady, blue.resetReady else {
            // Auto-expire after 5s if the other side never presses
            Task {
                try? await Task.sleep(for: .seconds(5))
                red.resetReady = false
                blue.resetReady = false
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            red.score = 0
            blue.score = 0
            showResetText = true
        }
        red.resetReady = false
        blue.resetReady = false

        Task {
            try? await Task.sleep(for: .seconds(1))
            withAnimation(.easeInOut(duration: 0.3)) {
                showResetText = false
            }
        }
    }
}

#Preview {
    ContentView()
}
