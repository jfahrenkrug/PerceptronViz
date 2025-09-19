//
//  TrainingProgressChartView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Charts

/// Visualizes epoch error trends and accompanying progress text.
struct TrainingProgressChartView: View {
    let epochChartData: [(epoch: Int, errors: Int)]
    let progressText: String
    let lastEpochErrors: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Training Progress")
                .font(.headline)
                .lineLimit(1)
            
            Chart(epochChartData, id: \.epoch) { data in
                LineMark(
                    x: .value("Epoch", data.epoch),
                    y: .value("Errors", data.errors)
                )
                .foregroundStyle(.red)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("Epoch", data.epoch),
                    y: .value("Errors", data.errors)
                )
                .foregroundStyle(data.errors == 0 ? .green : .red)
                .symbolSize(data.errors == 0 ? 80 : 60)
            }
            .frame(minHeight: 80, maxHeight: 120)
            .chartXAxisLabel("Epoch")
            .chartYAxisLabel("Total Errors")
            .chartYScale(domain: .automatic(includesZero: true))
            .border(Color.gray.opacity(0.3), width: 1)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(progressText)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let lastEpochErrors {
                    Text("Last Epoch Errors: \(lastEpochErrors)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}
