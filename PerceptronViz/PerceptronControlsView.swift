//
//  PerceptronControlsView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Offers manual weight tuning and live prediction feedback for the perceptron.
struct PerceptronControlsView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Perceptron Parameters")
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("W1 (Weight 1): \(model.w1, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.w1, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("W2 (Weight 2): \(model.w2, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.w2, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bias: \(model.bias, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.bias, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                }
                
                Text("Decision boundary: \(model.w1, specifier: "%.1f")×\(model.xAxisLabel) + \(model.w2, specifier: "%.1f")×\(model.yAxisLabel) + \(model.bias, specifier: "%.1f") = 0")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                    .frame(width: 350, alignment: .leading)
            }
            
            Divider()
                .frame(height: 80)
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Test Classification")
                    .font(.title3)
                    .fontWeight(.medium)
                
                HStack(alignment: .top, spacing: 20) {
                    VStack(alignment: .leading, spacing: 16) {
                        valueField(
                            title: model.xAxisLabel,
                            text: $model.inputX1,
                            decrement: { adjust(&model.inputX1, by: -0.5) },
                            increment: { adjust(&model.inputX1, by: 0.5) }
                        )
                        
                        valueField(
                            title: model.yAxisLabel,
                            text: $model.inputX2,
                            decrement: { adjust(&model.inputX2, by: -0.5) },
                            increment: { adjust(&model.inputX2, by: 0.5) }
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calculation:")
                                .font(.body)
                            Text(model.getCalculationDisplay())
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prediction:")
                                .font(.body)
                            Text(model.classifyInput())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(model.getClassificationColor())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    private func valueField(title: String, text: Binding<String>, decrement: @escaping () -> Void, increment: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(title):")
                .font(.body)
            HStack(spacing: 4) {
                TextField("Enter \(title)", text: text)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                    .font(.title2)
                
                Button("-") {
                    decrement()
                }
                .buttonStyle(.bordered)
                .frame(width: 30, height: 34)
                
                Button("+") {
                    increment()
                }
                .buttonStyle(.bordered)
                .frame(width: 30, height: 34)
            }
        }
    }
    
    private func adjust(_ value: inout String, by delta: Double) {
        if let current = Double(value) {
            value = String(format: "%.1f", current + delta)
        }
    }
}
