import Foundation
import SwiftUI

struct Dataset {
    let name: String
    let csvData: String
    let description: String
    let negativeLabel: String
    let positiveLabel: String
    
    init(name: String, csvData: String, description: String, negativeLabel: String = "FALSE", positiveLabel: String = "TRUE") {
        self.name = name
        self.csvData = csvData
        self.description = description
        self.negativeLabel = negativeLabel
        self.positiveLabel = positiveLabel
    }
}

@Observable
class PerceptronModel {
    var selectedDataset = "AND Gate"
    var csvText: String = "Input1,Input2,Output\n0,0,-1\n0,1,-1\n1,0,-1\n1,1,1"
    var dataPoints: [DataPoint] = []
    var w1: Double = 1.0
    var w2: Double = 1.0
    var bias: Double = -1.5
    
    // Chart scaling and pan/zoom
    var chartXRange: ClosedRange<Double> = -0.5...1.5
    var chartYRange: ClosedRange<Double> = -0.5...1.5
    
    // Headers from CSV
    var xAxisLabel: String = "X1"
    var yAxisLabel: String = "X2"
    var outputLabel: String = "Output"
    
    let datasets: [Dataset] = [
        Dataset(
            name: "AND Gate",
            csvData: "Input1,Input2,Output\n0,0,-1\n0,1,-1\n1,0,-1\n1,1,1",
            description: "Classic AND gate logic"
        ),
        Dataset(
            name: "OR Gate",
            csvData: "Input1,Input2,Output\n0,0,-1\n0,1,1\n1,0,1\n1,1,1",
            description: "Classic OR gate logic"
        ),
        Dataset(
            name: "Iris Flowers",
            csvData: "Sepal Length,Sepal Width,Species\n5.1,3.5,-1\n4.9,3.0,-1\n4.7,3.2,-1\n4.6,3.1,-1\n5.0,3.6,-1\n5.4,3.9,-1\n4.6,3.4,-1\n5.0,3.4,-1\n4.4,2.9,-1\n4.9,3.1,-1\n7.0,3.2,1\n6.4,3.2,1\n6.9,3.1,1\n5.5,2.3,1\n6.5,2.8,1\n5.7,2.8,1\n6.3,3.3,1\n4.9,2.4,1\n6.6,2.9,1\n5.2,2.7,1",
            description: "Setosa vs Versicolor iris flowers (sepal dimensions)",
            negativeLabel: "Setosa",
            positiveLabel: "Versicolor"
        ),
        Dataset(
            name: "UIKit vs SwiftUI",
            csvData: "Dev Time (hours),Bug Count,Framework\n8.5,2,-1\n12.0,1,-1\n15.2,3,-1\n18.7,2,-1\n22.1,4,-1\n25.3,3,-1\n28.9,5,-1\n32.4,4,-1\n35.8,6,-1\n40.2,5,-1\n3.2,8,1\n4.1,12,1\n2.8,15,1\n5.3,18,1\n3.9,22,1\n4.7,25,1\n2.4,28,1\n5.8,32,1\n3.6,35,1\n4.2,38,1",
            description: "Development time (hours) vs bugs: UIKit (slower, fewer bugs) vs SwiftUI (faster, more bugs)",
            negativeLabel: "UIKit",
            positiveLabel: "SwiftUI"
        )
    ]
    
    func parseCSV() {
        let lines = csvText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        guard !lines.isEmpty else {
            dataPoints = []
            return
        }
        
        var newDataPoints: [DataPoint] = []
        var startIndex = 0
        
        // Check if first line contains headers (non-numeric first column)
        let firstLineComponents = lines[0].components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        if firstLineComponents.count >= 3 && Double(firstLineComponents[0]) == nil {
            // First line contains headers
            xAxisLabel = firstLineComponents[0]
            yAxisLabel = firstLineComponents[1]
            outputLabel = firstLineComponents[2]
            startIndex = 1
        } else {
            // No headers, use defaults
            xAxisLabel = "X1"
            yAxisLabel = "X2"
            outputLabel = "Output"
            startIndex = 0
        }
        
        // Parse data lines
        for i in startIndex..<lines.count {
            let components = lines[i].components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            guard components.count >= 3,
                  let x = Double(components[0]),
                  let y = Double(components[1]),
                  let label = Int(components[2]) else {
                continue
            }
            
            newDataPoints.append(DataPoint(x: x, y: y, label: label))
        }
        
        dataPoints = newDataPoints
        updateChartScale()
    }
    
    func loadDataset(_ datasetName: String) {
        guard let dataset = datasets.first(where: { $0.name == datasetName }) else { return }
        selectedDataset = datasetName
        csvText = dataset.csvData
        parseCSV()
    }
    
    func updateChartScale() {
        guard !dataPoints.isEmpty else { return }
        
        let xValues = dataPoints.map { $0.x }
        let yValues = dataPoints.map { $0.y }
        
        let minX = xValues.min() ?? 0
        let maxX = xValues.max() ?? 1
        let minY = yValues.min() ?? 0
        let maxY = yValues.max() ?? 1
        
        let xPadding = max((maxX - minX) * 0.2, 0.1)
        let yPadding = max((maxY - minY) * 0.2, 0.1)
        
        chartXRange = (minX - xPadding)...(maxX + xPadding)
        chartYRange = (minY - yPadding)...(maxY + yPadding)
    }
    
    func zoomChart(scaleX: Double, scaleY: Double, centerX: Double, centerY: Double) {
        let currentXWidth = chartXRange.upperBound - chartXRange.lowerBound
        let currentYWidth = chartYRange.upperBound - chartYRange.lowerBound
        
        let newXWidth = currentXWidth / scaleX
        let newYWidth = currentYWidth / scaleY
        
        let newXMin = centerX - newXWidth / 2
        let newXMax = centerX + newXWidth / 2
        let newYMin = centerY - newYWidth / 2
        let newYMax = centerY + newYWidth / 2
        
        chartXRange = newXMin...newXMax
        chartYRange = newYMin...newYMax
    }
    
    func panChart(deltaX: Double, deltaY: Double) {
        let newXMin = chartXRange.lowerBound + deltaX
        let newXMax = chartXRange.upperBound + deltaX
        let newYMin = chartYRange.lowerBound + deltaY
        let newYMax = chartYRange.upperBound + deltaY
        
        chartXRange = newXMin...newXMax
        chartYRange = newYMin...newYMax
    }
    
    var currentDataset: Dataset? {
        datasets.first { $0.name == selectedDataset }
    }
    
    func decisionBoundaryLine(in xRange: ClosedRange<Double>, yRange: ClosedRange<Double>) -> [(x: Double, y: Double)]? {
        guard w2 != 0 else { return nil }
        
        var points: [(x: Double, y: Double)] = []
        
        // Check intersections with left and right edges (vertical)
        for x in [xRange.lowerBound, xRange.upperBound] {
            let y = -(w1 * x + bias) / w2
            if yRange.contains(y) {
                points.append((x: x, y: y))
            }
        }
        
        // Check intersections with top and bottom edges (horizontal)
        for y in [yRange.lowerBound, yRange.upperBound] {
            let x = -(w2 * y + bias) / w1
            if xRange.contains(x) {
                points.append((x: x, y: y))
            }
        }
        
        // Remove duplicates by rounding and filtering
        var uniquePoints: [(x: Double, y: Double)] = []
        for point in points {
            let roundedPoint = (x: round(point.x * 1000) / 1000, y: round(point.y * 1000) / 1000)
            let isDuplicate = uniquePoints.contains { existing in
                abs(existing.x - roundedPoint.x) < 0.001 && abs(existing.y - roundedPoint.y) < 0.001
            }
            if !isDuplicate {
                uniquePoints.append(roundedPoint)
            }
        }
        
        guard uniquePoints.count >= 2 else { return nil }
        
        // Return the first two points
        return Array(uniquePoints.prefix(2))
    }
}