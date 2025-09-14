import SwiftUI
import Charts

struct ContentView: View {
    @State private var model = PerceptronModel()
    
    var body: some View {
        HStack(spacing: 20) {
            leftPanel
            rightPanel
        }
        .padding()
        .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
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
                .frame(minHeight: 250)
            
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
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Perceptron Visualization")
                    .font(.headline)
                
                chartView
                
                legendView
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                    .padding(.vertical, 8)
                
                controlsView
                    .padding(.bottom, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .frame(minHeight: 300)
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
                .frame(height: 200)
            
            // Right side: Test Classification
            VStack(alignment: .leading, spacing: 16) {
                Text("Test Classification")
                    .font(.title3)
                    .fontWeight(.medium)
                
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Calculation:")
                            .font(.body)
                        Text(model.getCalculationDisplay())
                            .font(.system(.title3, design: .monospaced))
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
        }
        .padding(.horizontal)
    }
}