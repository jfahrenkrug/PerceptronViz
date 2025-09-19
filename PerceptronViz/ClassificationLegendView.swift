//
//  ClassificationLegendView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Displays the classification legend and chart auxiliary actions.
struct ClassificationLegendView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        HStack(spacing: 20) {
            legendItem(color: .red, text: "\(model.outputLabel): -1 (\(model.negativeDisplayLabel))")
            legendItem(color: .blue, text: "\(model.outputLabel): +1 (\(model.positiveDisplayLabel))")
            legendItem(color: .green, text: "Test Input")
            
            Spacer()
            
            Button("Reset View") {
                model.updateChartScale()
            }
            .buttonStyle(.bordered)
            .font(.caption)
            
            Button(model.showTrainingArea ? "Hide Training" : "Show Training") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    model.showTrainingArea.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding(.horizontal)
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(text)
                .font(.caption)
        }
    }
}
