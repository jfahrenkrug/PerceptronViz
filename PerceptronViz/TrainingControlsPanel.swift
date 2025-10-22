//
//  TrainingControlsPanel.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Provides controls for automated training, stepping, and reset actions.
struct TrainingControlsPanel: View {
    @Bindable var model: PerceptronModel
    @State private var isShowingSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text("Training Controls")
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Button {
                    isShowingSettings.toggle()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .labelStyle(.iconOnly)
                }
                .accessibilityLabel(Text("Training Settings"))
                .buttonStyle(.borderless)
                .popover(isPresented: $isShowingSettings, arrowEdge: .top) {
                    settingsPopover
                }
            }
            
            controlButtons
            
            if model.isTraining {
                Text("Current Point: \(model.trainingErrors.last?.wasError == true ? "❌" : "✅")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var controlButtons: some View {
        HStack(spacing: 8) {
            if model.isTraining {
                Button("Stop Training") {
                    model.stopTraining()
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.small)
            } else {
                Button("Start Training") {
                    model.startTraining()
                }
                .buttonStyle(.borderedProminent)
                .disabled(model.dataPoints.isEmpty)
                .controlSize(.small)
                
                Button("Step") {
                    model.stepTraining()
                }
                .buttonStyle(.bordered)
                .disabled(model.dataPoints.isEmpty)
                .controlSize(.small)
            }
            
            Button("Reset") {
                model.resetTraining()
            }
            .buttonStyle(.bordered)
            .disabled(model.isTraining)
            .controlSize(.small)
        }
    }
    
    private var settingsPopover: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Settings")
                .font(.headline)
            sliderSection(title: "Max Epochs: \(model.maxEpochs)") {
                Slider(
                    value: Binding(
                        get: { Double(model.maxEpochs) },
                        set: { model.maxEpochs = Int($0) }
                    ),
                    in: 10...500,
                    step: 10
                )
                .disabled(model.isTraining)
            }
            
            sliderSection(title: "Pause: \(model.pauseDuration.formatted(.number.precision(.fractionLength(1))))s") {
                Slider(
                    value: $model.pauseDuration,
                    in: 0.1...2.0,
                    step: 0.1
                )
                .disabled(model.isTraining)
            }
            
            sliderSection(title: "Learning Rate: \(model.learningRate.formatted(.number.precision(.fractionLength(2))))") {
                Slider(
                    value: $model.learningRate,
                    in: 0.01...1.0,
                    step: 0.01
                )
                .disabled(model.isTraining)
            }
        }
        .padding(16)
        .frame(width: 260)
    }
    
    private func sliderSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
            content()
        }
    }
}

