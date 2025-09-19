//
//  PerceptronChartView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Charts
import Observation

/// Renders the dataset points, decision boundary, and test input on a chart.
struct PerceptronChartView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        Chart {
            ForEach(model.dataPoints) { point in
                PointMark(
                    x: .value("X1", point.x),
                    y: .value("X2", point.y)
                )
                .foregroundStyle(model.colorForClassification(point.label))
                .symbolSize(100)
            }
            
            if !model.dataPoints.isEmpty,
               let boundaryPoints = model.decisionBoundaryLine(in: model.chartXRange, yRange: model.chartYRange),
               boundaryPoints.count >= 2 {
                LineMark(
                    x: .value("X", boundaryPoints[0].x),
                    y: .value("Y", boundaryPoints[0].y)
                )
                LineMark(
                    x: .value("X", boundaryPoints[1].x),
                    y: .value("Y", boundaryPoints[1].y)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
            
            if let inputPoint = model.inputPoint {
                PointMark(
                    x: .value("X1", inputPoint.x),
                    y: .value("X2", inputPoint.y)
                )
                .foregroundStyle(.green)
                .symbolSize(150)
                .symbol(.circle)
            }
        }
        .chartXScale(domain: model.chartXRange)
        .chartYScale(domain: model.chartYRange)
        .chartXAxisLabel(model.xAxisLabel)
        .chartYAxisLabel(model.yAxisLabel)
        .frame(minHeight: 120)
        .border(Color.gray, width: 1)
        .clipped()
        .onTapGesture(count: 2) {
            model.updateChartScale()
        }
        .help("Double-tap to reset view to fit data")
    }
}
