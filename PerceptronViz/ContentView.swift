import SwiftUI
import Charts

struct ContentView: View {
    @State private var model = PerceptronModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                leftPanel
                rightPanel
            }
            .padding()
            .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
            
            if model.showTrainingArea {
                trainingArea
            }
        }
        .onAppear {
            model.parseCSV()
        }
    }
    
    private var leftPanel: some View {
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
        .frame(width: 300)
    }
    
    private var rightPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Perceptron Visualization")
                .font(.headline)

            chartView

            legendView

            Divider()
                .padding(.vertical, 8)

            controlsView
                .padding(.bottom, 8)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var chartView: some View {
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
            
            // User input point
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
    
    private var controlsView: some View {
        HStack(alignment: .top, spacing: 24) {
            // Left side: Parameters
            VStack(alignment: .leading, spacing: 16) {
                Text("Perceptron Parameters")
                    .font(.title3)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("W1 (Weight 1): \(model.w1, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.w1, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("W2 (Weight 2): \(model.w2, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.w2, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Bias: \(model.bias, specifier: "%.1f")")
                            .font(.body)
                        Slider(value: $model.bias, in: -10...10, step: 0.1)
                            .frame(width: 280)
                    }
                }
                
                Text("Decision boundary: \(model.w1, specifier: "%.1f")×\(model.xAxisLabel) + \(model.w2, specifier: "%.1f")×\(model.yAxisLabel) + \(model.bias, specifier: "%.1f") = 0")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                    .frame(width: 350, alignment: .leading)
            }
            
            // Vertical divider
            Divider()
                .frame(height: 80)
            
            // Right side: Test Classification
            VStack(alignment: .leading, spacing: 16) {
                Text("Test Classification")
                    .font(.title3)
                    .fontWeight(.medium)

                HStack(alignment: .top, spacing: 20) {
                    // Left side: Input fields
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(model.xAxisLabel):")
                                .font(.body)
                            HStack(spacing: 4) {
                                TextField("Enter \(model.xAxisLabel)", text: $model.inputX1)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                    .font(.title2)

                                Button("-") {
                                    if let current = Double(model.inputX1) {
                                        model.inputX1 = String(format: "%.1f", current - 0.5)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .frame(width: 30, height: 34)

                                Button("+") {
                                    if let current = Double(model.inputX1) {
                                        model.inputX1 = String(format: "%.1f", current + 0.5)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .frame(width: 30, height: 34)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(model.yAxisLabel):")
                                .font(.body)
                            HStack(spacing: 4) {
                                TextField("Enter \(model.yAxisLabel)", text: $model.inputX2)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 100)
                                    .font(.title2)

                                Button("-") {
                                    if let current = Double(model.inputX2) {
                                        model.inputX2 = String(format: "%.1f", current - 0.5)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .frame(width: 30, height: 34)

                                Button("+") {
                                    if let current = Double(model.inputX2) {
                                        model.inputX2 = String(format: "%.1f", current + 0.5)
                                    }
                                }
                                .buttonStyle(.bordered)
                                .frame(width: 30, height: 34)
                            }
                        }
                    }

                    // Right side: Calculation and Prediction
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Calculation:")
                                .font(.body)
                            Text(model.getCalculationDisplay())
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 10)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(6)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prediction:")
                                .font(.body)
                            Text(model.classifyInput())
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(model.getClassificationColor())
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            Spacer()
        }
    }
    
    
    private var legendView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                Text("\(model.outputLabel): -1 (\(model.negativeDisplayLabel))")
                    .font(.caption)
            }
            
            HStack(spacing: 6) {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                Text("\(model.outputLabel): +1 (\(model.positiveDisplayLabel))")
                    .font(.caption)
            }
            
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                Text("Test Input")
                    .font(.caption)
            }
            
            Spacer()
            
            Button("Reset View") {
                model.updateChartScale()
            }
            .buttonStyle(.bordered)
            .font(.caption)
            
            Button(model.showTrainingArea ? "Hide Training" : "Show Training") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    model.showTrainingArea.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .font(.caption)
        }
        .padding(.horizontal)
    }
    
    private var trainingArea: some View {
        VStack(spacing: 0) {
            Divider()

            VStack(spacing: 8) {
                HStack(alignment: .top, spacing: 16) {
                    // Training Chart
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Training Progress")
                            .font(.headline)
                            .lineLimit(1)

                        Chart(model.epochChartData, id: \.epoch) { data in
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

                        // Progress labels below chart
                        VStack(alignment: .leading, spacing: 2) {
                            Text(model.epochProgressString)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .lineLimit(1)

                            if let lastEpochErrors = model.epochErrors.last {
                                Text("Last Epoch Errors: \(lastEpochErrors)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Divider()

                    // Data Points Table
                    dataPointsTable()
                        .frame(width: 200)
                        .frame(maxHeight: .infinity)

                    Divider()

                    // Calculation Details
                    stepCalculationDetails(for: model.trainingErrors.last)
                        .frame(width: 500)
                        .frame(maxHeight: .infinity)

                    Divider()
                    
                    // Training Controls
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Training Controls")
                            .font(.headline)
                            .lineLimit(1)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Max Epochs: \(model.maxEpochs)")
                                        .font(.caption)
                                    Slider(value: Binding(
                                        get: { Double(model.maxEpochs) },
                                        set: { model.maxEpochs = Int($0) }
                                    ), in: 10...500, step: 10)
                                    .frame(width: 200)
                                    .disabled(model.isTraining)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Pause: \(model.pauseDuration, specifier: "%.1f")s")
                                        .font(.caption)
                                    Slider(value: $model.pauseDuration, in: 0.1...2.0, step: 0.1)
                                        .frame(width: 200)
                                        .disabled(model.isTraining)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Learning Rate: \(model.learningRate, specifier: "%.2f")")
                                        .font(.caption)
                                    Slider(value: $model.learningRate, in: 0.01...1.0, step: 0.01)
                                        .frame(width: 200)
                                        .disabled(model.isTraining)
                                }

                                HStack(spacing: 8) {
                                    if model.isTraining {
                                        Button("Stop Training") {
                                            model.stopTraining()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.red)
                                        .font(.caption)
                                    } else {
                                        Button("Start Training") {
                                            model.startTraining()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .disabled(model.dataPoints.isEmpty)
                                        .font(.caption)

                                        Button("Step") {
                                            model.stepTraining()
                                        }
                                        .buttonStyle(.bordered)
                                        .disabled(model.dataPoints.isEmpty)
                                        .font(.caption)
                                    }

                                    Button("Reset") {
                                        model.resetTraining()
                                    }
                                    .buttonStyle(.bordered)
                                    .disabled(model.isTraining)
                                    .font(.caption)
                                }

                                if model.isTraining {
                                    Text("Current Point: \(model.trainingErrors.last?.wasError == true ? "❌" : "✅")")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .frame(width: 250)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 300)
        .background(Color.gray.opacity(0.05))
    }
    
    @ViewBuilder
    private func stepCalculationDetails(for step: TrainingError?) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(step != nil ? "Step \(step!.step) Calculation Details" : "Training Calculation Details")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            if let step = step,
               let point = step.currentPoint,
               let prediction = step.prediction,
               let actual = step.actualLabel {
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Training Point:")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("(\(String(format: "%.1f", point.x)), \(String(format: "%.1f", point.y))) → \(actual)")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Prediction:")
                            .font(.body)
                            .fontWeight(.medium)
                        Text("\(prediction)")
                            .font(.body)
                            .foregroundColor(step.wasError ? .red : .green)
                            .fontWeight(.bold)
                        Text(step.wasError ? "(❌ Error)" : "(✅ Correct)")
                            .font(.body)
                            .foregroundColor(step.wasError ? .red : .green)
                    }
                    
                    // Fixed height content area to prevent jumping
                    VStack(alignment: .leading, spacing: 12) {
                        if step.wasError,
                           let oldWeights = step.oldWeights,
                           let newWeights = step.newWeights,
                           let lr = step.learningRate {
                            
                            Text("Weight Updates (Error = \(actual) - \(prediction) = \(actual - prediction))")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                let errorValue = Double(actual - prediction)
                                
                                // W1 calculation with labels
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("W1:")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(width: 60, alignment: .leading)
                                            .fontWeight(.medium)
                                        Text("\(String(format: "%.2f", oldWeights.w1)) + (\(String(format: "%.2f", lr)) × \(errorValue, specifier: "%.0f") × \(String(format: "%.1f", point.x))) = \(String(format: "%.2f", newWeights.w1))")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Text("     old     + (rate × err × inp)    = new")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.orange)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                // W2 calculation with labels
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("W2:")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(width: 60, alignment: .leading)
                                            .fontWeight(.medium)
                                        Text("\(String(format: "%.2f", oldWeights.w2)) + (\(String(format: "%.2f", lr)) × \(errorValue, specifier: "%.0f") × \(String(format: "%.1f", point.y))) = \(String(format: "%.2f", newWeights.w2))")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Text("     old     + (rate × err × inp)    = new")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.orange)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 60)
                                }
                                
                                // Bias calculation with labels
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("Bias:")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(width: 60, alignment: .leading)
                                            .fontWeight(.medium)
                                        Text("\(String(format: "%.2f", oldWeights.bias)) + (\(String(format: "%.2f", lr)) × \(errorValue, specifier: "%.0f") × 1) = \(String(format: "%.2f", newWeights.bias))")
                                            .font(.system(.title3, design: .monospaced))
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    HStack {
                                        Text("      old     + (rate × err × 1)     = new")
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.orange)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading, 60)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        } else {
                            VStack {
                                Text("No weight updates needed - prediction was correct!")
                                    .font(.body)
                                    .foregroundColor(.green)
                                    .italic()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                            }
                            .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            } else {
                Text("No training step data available yet")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func dataPointsTable() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Training Data")
                .font(.headline)
            
            ScrollView {
                VStack(spacing: 2) {
                    // Header
                    HStack(spacing: 4) {
                        Text("#")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 25, alignment: .center)
                        Text(model.xAxisLabel)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(width: 50, alignment: .center)
                        Text(model.yAxisLabel)
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
                    
                    // Data rows
                    ForEach(Array(model.dataPoints.enumerated()), id: \.element.id) { index, point in
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
                                .foregroundColor(model.colorForClassification(point.label))
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
        guard let lastStep = model.trainingErrors.last,
              let currentPoint = lastStep.currentPoint else {
            return false
        }
        
        // Find the matching data point
        return model.dataPoints[safe: index]?.x == currentPoint.x &&
               model.dataPoints[safe: index]?.y == currentPoint.y &&
               model.dataPoints[safe: index]?.label == currentPoint.label
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}