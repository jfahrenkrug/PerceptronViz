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
            
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 16) {
                    VStack(spacing: 12) {
                        TrainingProgressChartView(
                            epochChartData: model.epochChartData,
                            progressText: model.epochProgressString,
                            lastEpochErrors: model.epochErrors.last
                        )
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .layoutPriority(1)
                        
                        Divider()
                        
                        TrainingControlsPanel(model: model)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    Divider()
                    
                    StepCalculationDetailsView(step: model.trainingErrors.last)
                        .frame(width: 520)
                        .frame(maxHeight: .infinity)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: 340)
        .background(Color.gray.opacity(0.05))
    }
}
