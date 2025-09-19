//
//  TrainingDataTableView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI

/// Lists training samples and highlights the current point under evaluation.
struct TrainingDataTableView: View {
    let dataPoints: [DataPoint]
    let xAxisLabel: String
    let yAxisLabel: String
    let lastTrainingStep: TrainingError?
    let colorProvider: (Int) -> Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training Data")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 2) {
                    HStack(spacing: 4) {
                        Text("#")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 25, alignment: .center)
                        Text(xAxisLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .center)
                        Text(yAxisLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .center)
                        Text("Label")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 40, alignment: .center)
                    }
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
                    
                    ForEach(Array(dataPoints.enumerated()), id: \.element.id) { index, point in
                        let isCurrentStep = isCurrentTrainingPoint(index: index)
                        
                        HStack(spacing: 4) {
                            Text("\(index + 1)")
                                .font(.caption)
                                .frame(width: 25, alignment: .center)
                            Text(String(format: "%.1f", point.x))
                                .font(.system(.caption, design: .monospaced))
                                .frame(width: 50, alignment: .center)
                            Text(String(format: "%.1f", point.y))
                                .font(.system(.caption, design: .monospaced))
                                .frame(width: 50, alignment: .center)
                            Text("\(point.label)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .frame(width: 40, alignment: .center)
                                .foregroundColor(colorProvider(point.label))
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 4)
                        .background(isCurrentStep ? Color.yellow.opacity(0.3) : Color.clear)
                        .cornerRadius(4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(isCurrentStep ? Color.orange : Color.clear, lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func isCurrentTrainingPoint(index: Int) -> Bool {
        guard let currentPoint = lastTrainingStep?.currentPoint,
              let candidate = dataPoints[safe: index] else {
            return false
        }
        
        return candidate.x == currentPoint.x &&
               candidate.y == currentPoint.y &&
               candidate.label == currentPoint.label
    }
}
