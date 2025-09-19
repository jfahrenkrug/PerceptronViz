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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Training Controls")
                .font(.headline)
                .lineLimit(1)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Epochs: \(model.maxEpochs)")
                            .font(.caption)
                        Slider(value: Binding(
                            get: { Double(model.maxEpochs) },
                            set: { model.maxEpochs = Int($0) }
                        ), in: 10...500, step: 10)
                        .frame(width: 200)
                        .disabled(model.isTraining)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pause: \(model.pauseDuration, specifier: "%.1f")s")
                            .font(.caption)
                        Slider(value: $model.pauseDuration, in: 0.1...2.0, step: 0.1)
                            .frame(width: 200)
                            .disabled(model.isTraining)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Learning Rate: \(model.learningRate, specifier: "%.2f")")
                            .font(.caption)
                        Slider(value: $model.learningRate, in: 0.01...1.0, step: 0.01)
                            .frame(width: 200)
                            .disabled(model.isTraining)
                    }
                    
                    HStack(spacing: 8) {
                        if model.isTraining {
                            Button("Stop Training") {
                                model.stopTraining()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .font(.caption)
                        } else {
                            Button("Start Training") {
                                model.startTraining()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(model.dataPoints.isEmpty)
                            .font(.caption)
                            
                            Button("Step") {
                                model.stepTraining()
                            }
                            .buttonStyle(.bordered)
                            .disabled(model.dataPoints.isEmpty)
                            .font(.caption)
                        }
                        
                        Button("Reset") {
                            model.resetTraining()
                        }
                        .buttonStyle(.bordered)
                        .disabled(model.isTraining)
                        .font(.caption)
                    }
                    
                    if model.isTraining {
                        Text("Current Point: \(model.trainingErrors.last?.wasError == true ? "❌" : "✅")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
