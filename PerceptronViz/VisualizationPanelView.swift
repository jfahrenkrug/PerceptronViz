//
//  VisualizationPanelView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Coordinates the chart, legend, and perceptron interaction controls.
struct VisualizationPanelView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Perceptron Visualization")
                .font(.headline)
            
            PerceptronChartView(model: model)
            
            ClassificationLegendView(model: model)
            
            Divider()
                .padding(.vertical, 8)
            
            PerceptronControlsView(model: model)
                .padding(.bottom, 8)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
