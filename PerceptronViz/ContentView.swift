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
        .frame(minWidth: 1000, minHeight: 600)
        .onAppear {
            model.parseCSV()
        }
    }
    
    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Data (CSV)")
                .font(.headline)
            
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
            
            Text("Format: x1,x2,label")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $model.csvText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray, width: 1)
                .frame(minHeight: 250)
            
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
            
            controlsView
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
                .foregroundStyle(point.label == -1 ? .red : .blue)
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
        }
        .chartXScale(domain: model.chartXRange)
        .chartYScale(domain: model.chartYRange)
        .chartXAxisLabel(model.xAxisLabel)
        .chartYAxisLabel(model.yAxisLabel)
        .frame(height: 400)
        .border(Color.gray, width: 1)
        .clipped()
        .onTapGesture(count: 2) {
            model.updateChartScale()
        }
        .help("Double-tap to reset view to fit data")
    }
    
    private var controlsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Perceptron Parameters")
                .font(.subheadline)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("W1 (Weight 1): \(model.w1, specifier: "%.1f")")
                        .font(.caption)
                    Slider(value: $model.w1, in: -10...10, step: 0.1)
                        .frame(width: 250)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("W2 (Weight 2): \(model.w2, specifier: "%.1f")")
                        .font(.caption)
                    Slider(value: $model.w2, in: -10...10, step: 0.1)
                        .frame(width: 250)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bias: \(model.bias, specifier: "%.1f")")
                    .font(.caption)
                
                Slider(value: $model.bias, in: -10...10, step: 0.1)
                    .frame(width: 250)
            }
            
            Text("Decision boundary: \(model.w1, specifier: "%.1f")×\(model.xAxisLabel) + \(model.w2, specifier: "%.1f")×\(model.yAxisLabel) + \(model.bias, specifier: "%.1f") = 0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
    
    
    private var legendView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 6) {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                Text("\(model.outputLabel): -1 (\(model.currentDataset?.negativeLabel ?? "FALSE"))")
                    .font(.caption)
            }
            
            HStack(spacing: 6) {
                Circle()
                    .fill(.blue)
                    .frame(width: 12, height: 12)
                Text("\(model.outputLabel): +1 (\(model.currentDataset?.positiveLabel ?? "TRUE"))")
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