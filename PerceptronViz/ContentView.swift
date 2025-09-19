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
            HStack(spacing: 20) {
                TrainingDataEditorView(model: model)
                    .frame(width: 300)
                
                VisualizationPanelView(model: model)
            }
            .padding()
            .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            
            if model.showTrainingArea {
                TrainingAreaView(model: model)
            }
        }
        .onAppear {
            model.parseCSV()
        }
    }
}
