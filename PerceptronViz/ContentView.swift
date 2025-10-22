//
//  ContentView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI

/// Hosts the overall layout by composing data input, visualization, and training panels.
struct ContentView: View {
    @State private var model = PerceptronModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 24) {
                TrainingDataEditorView(model: model)
                    .frame(width: 340)
                    .frame(maxHeight: .infinity)
                
                VisualizationPanelView(model: model)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .frame(minWidth: 1080, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            
            if model.showTrainingArea {
                TrainingAreaView(model: model)
            }
        }
        .onAppear {
            model.parseCSV()
        }
    }
}
