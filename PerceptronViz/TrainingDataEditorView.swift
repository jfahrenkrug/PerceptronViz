//
//  TrainingDataEditorView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Presents controls for editing or selecting CSV training datasets.
struct TrainingDataEditorView: View {
    @Bindable var model: PerceptronModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Data (CSV)")
                .font(.headline)
            
            TextEditor(text: $model.csvText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray, width: 1)
                .frame(minHeight: 150)
            
            Text("Format: x1,x2,label")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Dataset:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Dataset", selection: $model.selectedDataset) {
                    ForEach(model.datasets, id: \.name) { dataset in
                        Text(dataset.name).tag(dataset.name)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: model.selectedDataset) { _, newValue in
                    model.loadDataset(newValue)
                }
            }
            
            Button("Parse Data") {
                model.parseCSV()
            }
            .buttonStyle(.borderedProminent)
            
            if !model.dataPoints.isEmpty {
                Text("Parsed \(model.dataPoints.count) data points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}
