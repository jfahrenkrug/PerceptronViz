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
    }
    
    private var leftPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Training Data (CSV)")
                .font(.headline)
            
            Text("Format: x1,x2,label")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextEditor(text: $model.csvText)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray, width: 1)
                .frame(minHeight: 300)
            
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
                .foregroundStyle(point.label == 0 ? .red : .blue)
                .symbolSize(100)
            }
            
            if !model.dataPoints.isEmpty,
               let xRange = xAxisRange,
               let boundaryLine = model.decisionBoundaryLine(in: xRange) {
                LineMark(
                    x: .value("X", boundaryLine.start.x),
                    y: .value("Y", boundaryLine.start.y)
                )
                LineMark(
                    x: .value("X", boundaryLine.end.x),
                    y: .value("Y", boundaryLine.end.y)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 3))
            }
        }
        .chartXAxisLabel("X1")
        .chartYAxisLabel("X2")
        .frame(height: 400)
        .border(Color.gray, width: 1)
    }
    
    private var controlsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Perceptron Parameters")
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("W1 (Weight 1)")
                        .font(.caption)
                    TextField("W1", value: $model.w1, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
                
                VStack(alignment: .leading) {
                    Text("W2 (Weight 2)")
                        .font(.caption)
                    TextField("W2", value: $model.w2, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 100)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Bias: \(model.bias, specifier: "%.2f")")
                    .font(.caption)
                
                Slider(value: $model.bias, in: -5...5)
                    .frame(width: 200)
            }
            
            Text("Decision boundary: \(model.w1, specifier: "%.2f")x₁ + \(model.w2, specifier: "%.2f")x₂ + \(model.bias, specifier: "%.2f") = 0")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    }
    
    private var xAxisRange: ClosedRange<Double>? {
        guard !model.dataPoints.isEmpty else { return nil }
        let xValues = model.dataPoints.map { $0.x }
        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 0
        let padding = (maxX - minX) * 0.1
        return (minX - padding)...(maxX + padding)
    }
}