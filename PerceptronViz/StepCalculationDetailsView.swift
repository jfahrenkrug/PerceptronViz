//
//  StepCalculationDetailsView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI

/// Breaks down the perceptron calculation and weight updates for a training step.
struct StepCalculationDetailsView: View {
    let step: TrainingError?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(step != nil ? "Step \(step!.step) Calculation Details" : "Training Calculation Details")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let step,
               let point = step.currentPoint,
               let prediction = step.prediction,
               let actual = step.actualLabel {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Training Point:")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("(\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y))) → \(actual)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Prediction:")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("\(prediction)")
                            .font(.body)
                            .foregroundColor(step.wasError ? .red : .green)
                            .fontWeight(.bold)
                        Text(step.wasError ? "(❌ Error)" : "(✅ Correct)")
                            .font(.body)
                            .foregroundColor(step.wasError ? .red : .green)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if step.wasError,
                           let oldWeights = step.oldWeights,
                           let newWeights = step.newWeights,
                           let lr = step.learningRate {
                            Text("Weight Updates (Error = \(actual) - \(prediction) = \(actual - prediction))")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                let errorValue = Double(actual - prediction)
                                
                                weightCalculationRow(
                                    title: "W1:",
                                    oldValue: oldWeights.w1,
                                    learningRate: lr,
                                    errorValue: errorValue,
                                    inputText: String(format: "%.1f", point.x),
                                    newValue: newWeights.w1,
                                    placeholderText: "     old     + (rate × err × inp)    = new"
                                )
                                
                                weightCalculationRow(
                                    title: "W2:",
                                    oldValue: oldWeights.w2,
                                    learningRate: lr,
                                    errorValue: errorValue,
                                    inputText: String(format: "%.1f", point.y),
                                    newValue: newWeights.w2,
                                    placeholderText: "     old     + (rate × err × inp)    = new"
                                )
                                
                                weightCalculationRow(
                                    title: "Bias:",
                                    oldValue: oldWeights.bias,
                                    learningRate: lr,
                                    errorValue: errorValue,
                                    inputText: "1",
                                    newValue: newWeights.bias,
                                    placeholderText: "      old     + (rate × err × 1)     = new"
                                )
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        } else {
                            VStack {
                                Text("No weight updates needed - prediction was correct!")
                                    .font(.body)
                                    .foregroundColor(.green)
                                    .italic()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                Text("No training step data available yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    private func weightCalculationRow(
        title: String,
        oldValue: Double,
        learningRate: Double,
        errorValue: Double,
        inputText: String,
        newValue: Double,
        placeholderText: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                Text(title)
                    .font(.system(.title3, design: .monospaced))
                    .frame(width: 60, alignment: .leading)
                    .fontWeight(.medium)
                Text("\(String(format: "%.2f", oldValue)) + (\(String(format: "%.2f", learningRate)) × \(errorValue, specifier: "%.0f") × \(inputText)) = \(String(format: "%.2f", newValue))")
                    .font(.system(.title3, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            HStack {
                Text(placeholderText)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.leading, 60)
        }
    }
}
