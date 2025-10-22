//
//  TrainingAreaView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Shows training progress metrics alongside detailed step analysis tools.
struct TrainingAreaView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 16) {
                    TrainingProgressChartView(
                        epochChartData: model.epochChartData,
                        progressText: model.epochProgressString,
                        lastEpochErrors: model.epochErrors.last
                    )
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                    
                    StepCalculationDetailsView(step: model.trainingErrors.last)
                        .frame(width: 520)
                        .frame(maxHeight: .infinity)
                    
                    Divider()
                    
                    TrainingControlsPanel(model: model)
                        .frame(width: 250)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .background(Color.gray.opacity(0.05))
    }
}
