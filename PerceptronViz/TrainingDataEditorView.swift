//
//  TrainingDataEditorView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI
import Observation

/// Presents controls for browsing and editing training datasets.
struct TrainingDataEditorView: View {
    @Bindable var model: PerceptronModel
    @State private var isEditingCSV = false
    @State private var csvDraft: String

    init(model: PerceptronModel) {
        self._model = Bindable(model)
        _csvDraft = State(initialValue: model.csvText)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            TrainingDataTableView(
                dataPoints: model.dataPoints,
                xAxisLabel: model.xAxisLabel,
                yAxisLabel: model.yAxisLabel,
                lastTrainingStep: model.trainingErrors.last,
                colorProvider: model.colorForClassification
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(maxHeight: .infinity, alignment: .top)
            
            HStack(spacing: 12) {
                Picker("Dataset", selection: $model.selectedDataset) {
                    ForEach(model.datasets, id: \.name) { dataset in
                        Text(dataset.name).tag(dataset.name)
                    }
                }
                .frame(width: 200)
                .pickerStyle(.menu)
                .onChange(of: model.selectedDataset) { _, newValue in
                    model.loadDataset(newValue)
                }
                
                Spacer()

                Button("Edit") {
                    csvDraft = model.csvText
                    isEditingCSV = true
                }
                .buttonStyle(.bordered)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .sheet(isPresented: $isEditingCSV) {
            csvEditorSheet
        }
        .onChange(of: model.csvText) { newValue in
            guard !isEditingCSV else { return }
            csvDraft = newValue
        }
    }
    
    private var csvEditorSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Edit dataset CSV")
                    .font(.headline)
                
                Text("Format: x1,x2,label")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextEditor(text: $csvDraft)
                    .font(.system(.body, design: .monospaced))
                    .border(Color.gray.opacity(0.5), width: 1)
                    .frame(minHeight: 240)
                    .frame(maxHeight: .infinity)
                    .layoutPriority(1)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(minWidth: 520, minHeight: 440)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    isEditingCSV = false
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save & Parse") {
                    model.csvText = csvDraft
                    model.parseCSV()
                    isEditingCSV = false
                }
                .disabled(csvDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
