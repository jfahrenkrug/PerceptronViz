import Foundation
import SwiftUI

struct Dataset {
    let name: String
    let csvData: String
    let description: String
}

@Observable @MainActor
class PerceptronModel {
    var selectedDataset = "AND Gate"
    var csvText: String = "Input1,Input2,Classification,Label\n0,0,-1,False\n0,1,-1,False\n1,0,-1,False\n1,1,1,True"
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
    
    // Display labels from CSV (4th column)
    var negativeDisplayLabel: String = "FALSE"
    var positiveDisplayLabel: String = "TRUE"
    
    // Interactive prediction inputs
    var inputX1: String = "0.5"
    var inputX2: String = "0.5"
    
    // Training state
    var isTraining: Bool = false
    var showTrainingArea: Bool = false
    var maxEpochs: Int = 100
    var pauseDuration: Double = 0.5
    var currentEpoch: Int = 0
    var currentStep: Int = 0
    var trainingErrors: [TrainingError] = []
    var learningRate: Double = 0.1
    var shuffledPoints: [DataPoint] = []
    var currentPointIndex: Int = 0
    
    let datasets: [Dataset] = [
        Dataset(
            name: "AND Gate",
            csvData: "Input1,Input2,Classification,Label\n0,0,-1,False\n0,1,-1,False\n1,0,-1,False\n1,1,1,True",
            description: "Classic AND gate logic"
        ),
        Dataset(
            name: "OR Gate",
            csvData: "Input1,Input2,Classification,Label\n0,0,-1,False\n0,1,1,True\n1,0,1,True\n1,1,1,True",
            description: "Classic OR gate logic"
        ),
        Dataset(
            name: "Iris Flowers",
            csvData: "Sepal Length,Sepal Width,Classification,Species\n5.1,3.5,-1,Setosa\n4.9,3.0,-1,Setosa\n4.7,3.2,-1,Setosa\n4.6,3.1,-1,Setosa\n5.0,3.6,-1,Setosa\n5.4,3.9,-1,Setosa\n4.6,3.4,-1,Setosa\n5.0,3.4,-1,Setosa\n4.4,2.9,-1,Setosa\n4.9,3.1,-1,Setosa\n7.0,3.2,1,Versicolor\n6.4,3.2,1,Versicolor\n6.9,3.1,1,Versicolor\n5.5,2.3,1,Versicolor\n6.5,2.8,1,Versicolor\n5.7,2.8,1,Versicolor\n6.3,3.3,1,Versicolor\n4.9,2.4,1,Versicolor\n6.6,2.9,1,Versicolor\n5.2,2.7,1,Versicolor",
            description: "Setosa vs Versicolor iris flowers (sepal dimensions)"
        ),
        Dataset(
            name: "UIKit vs SwiftUI",
            csvData: "Dev Time (hours),Bug Count,Classification,Framework\n8.5,2,1,UIKit\n12.0,1,1,UIKit\n15.2,3,1,UIKit\n18.7,2,1,UIKit\n22.1,4,1,UIKit\n25.3,3,1,UIKit\n28.9,5,1,UIKit\n32.4,4,1,UIKit\n35.8,6,1,UIKit\n40.2,5,1,UIKit\n3.2,8,-1,SwiftUI\n4.1,12,-1,SwiftUI\n2.8,15,-1,SwiftUI\n5.3,18,-1,SwiftUI\n3.9,22,-1,SwiftUI\n4.7,25,-1,SwiftUI\n2.4,28,-1,SwiftUI\n5.8,32,-1,SwiftUI\n3.6,35,-1,SwiftUI\n4.2,38,-1,SwiftUI",
            description: "Development time (hours) vs bugs: UIKit (slower, fewer bugs) vs SwiftUI (faster, more bugs)"
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
        
        if firstLineComponents.count >= 4 && Double(firstLineComponents[0]) == nil {
            // First line contains headers
            xAxisLabel = firstLineComponents[0]
            yAxisLabel = firstLineComponents[1] 
            outputLabel = firstLineComponents[2]
            startIndex = 1
        } else {
            // No headers, use defaults
            xAxisLabel = "X1"
            yAxisLabel = "X2"
            outputLabel = "Classification"
            startIndex = 0
        }
        
        // Track display labels for -1 and +1
        var negativeLabel: String? = nil
        var positiveLabel: String? = nil
        
        // Parse data rows: x1, x2, classification, label
        for i in startIndex..<lines.count {
            let components = lines[i].components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            
            guard components.count >= 4,
                  let x = Double(components[0]),
                  let y = Double(components[1]),
                  let classification = Int(components[2]) else {
                continue
            }
            
            let displayLabel = components[3]
            
            // Store display labels
            if classification == -1 && negativeLabel == nil {
                negativeLabel = displayLabel
            }
            if classification == 1 && positiveLabel == nil {
                positiveLabel = displayLabel
            }
            
            newDataPoints.append(DataPoint(x: x, y: y, label: classification))
        }
        
        // Update display labels
        negativeDisplayLabel = negativeLabel ?? "FALSE"
        positiveDisplayLabel = positiveLabel ?? "TRUE"
        
        dataPoints = newDataPoints
        updateChartScale()
        initializePerceptronParameters()
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
    
    func initializePerceptronParameters() {
        guard !dataPoints.isEmpty else { return }
        
        // Separate positive and negative examples
        let positivePoints = dataPoints.filter { $0.label == 1 }
        let negativePoints = dataPoints.filter { $0.label == -1 }
        
        guard !positivePoints.isEmpty && !negativePoints.isEmpty else { return }
        
        // Calculate centroids
        let positiveCentroid = (
            x: positivePoints.map { $0.x }.reduce(0, +) / Double(positivePoints.count),
            y: positivePoints.map { $0.y }.reduce(0, +) / Double(positivePoints.count)
        )
        let negativeCentroid = (
            x: negativePoints.map { $0.x }.reduce(0, +) / Double(negativePoints.count),
            y: negativePoints.map { $0.y }.reduce(0, +) / Double(negativePoints.count)
        )
        
        // Set weights to separate the centroids
        let deltaX = positiveCentroid.x - negativeCentroid.x
        let deltaY = positiveCentroid.y - negativeCentroid.y
        
        // Normalize and set weights
        let magnitude = sqrt(deltaX * deltaX + deltaY * deltaY)
        if magnitude > 0 {
            w1 = deltaX / magnitude
            w2 = deltaY / magnitude
            
            // Set bias to position boundary between centroids
            let midpointX = (positiveCentroid.x + negativeCentroid.x) / 2
            let midpointY = (positiveCentroid.y + negativeCentroid.y) / 2
            bias = -(w1 * midpointX + w2 * midpointY)
        }
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
    
    // MARK: - Centralized Perceptron Prediction
    
    func predict(x1: Double, x2: Double) -> Int {
        let result = w1 * x1 + w2 * x2 + bias
        return result >= 0 ? 1 : -1
    }
    
    func debugPrediction(x1: Double, x2: Double) -> String {
        let result = w1 * x1 + w2 * x2 + bias
        let prediction = result >= 0 ? 1 : -1
        let label = prediction == -1 ? negativeDisplayLabel : positiveDisplayLabel
        return "Input: (\(x1), \(x2)) → \(w1)*\(x1) + \(w2)*\(x2) + \(bias) = \(result) → \(prediction) → \(label)"
    }
    
    var currentPrediction: Int? {
        guard let x1 = Double(inputX1), let x2 = Double(inputX2) else {
            return nil
        }
        return predict(x1: x1, x2: x2)
    }
    
    func classifyInput() -> String {
        guard let prediction = currentPrediction else {
            return "Invalid input"
        }
        return prediction == -1 ? negativeDisplayLabel : positiveDisplayLabel
    }
    
    func getClassificationColor() -> Color {
        guard let prediction = currentPrediction else {
            return .primary
        }
        return colorForClassification(prediction)
    }
    
    func getCalculationDisplay() -> String {
        guard let x1 = Double(inputX1), let x2 = Double(inputX2) else {
            return "Invalid input"
        }
        
        let result = w1 * x1 + w2 * x2 + bias
        let prediction = result >= 0 ? 1 : -1
        
        return "(\(String(format: "%.1f", x1)) × \(String(format: "%.1f", w1))) + (\(String(format: "%.1f", x2)) × \(String(format: "%.1f", w2))) + \(String(format: "%.1f", bias)) = \(String(format: "%.2f", result))\nActivation: \(String(format: "%.2f", result)) ≥ 0 ? → \(prediction)"
    }
    
    func colorForClassification(_ classification: Int) -> Color {
        // Consistent with chart coloring: -1 = red, +1 = blue
        return classification == -1 ? .red : .blue
    }
    
    // MARK: - Training Methods
    
    func startTraining() {
        guard !dataPoints.isEmpty && !isTraining else { return }
        isTraining = true
        currentEpoch = 0
        currentStep = 0
        trainingErrors = []
        shuffledPoints = dataPoints.shuffled()
        currentPointIndex = 0
        continueTraining()
    }
    
    private func continueTraining() {
        guard isTraining && currentEpoch < maxEpochs else {
            isTraining = false
            return
        }
        
        performTrainingStep()
        
        if isTraining {
            DispatchQueue.main.asyncAfter(deadline: .now() + pauseDuration) {
                self.continueTraining()
            }
        }
    }
    
    func stopTraining() {
        isTraining = false
    }
    
    func stepTraining() {
        guard !dataPoints.isEmpty && !isTraining else { return }
        if currentStep == 0 {
            // Initialize for manual stepping
            shuffledPoints = dataPoints.shuffled()
            currentPointIndex = 0
            currentEpoch = 0
        }
        performTrainingStep()
    }
    
    private func performTrainingStep() {
        // Check if we need to start a new epoch
        if currentPointIndex >= shuffledPoints.count {
            currentEpoch += 1
            currentPointIndex = 0
            shuffledPoints = dataPoints.shuffled()
            
            // Stop if we've reached max epochs
            if currentEpoch >= maxEpochs {
                isTraining = false
                return
            }
        }
        
        // Get the current point to train on
        let point = shuffledPoints[currentPointIndex]
        let prediction = predict(x1: point.x, x2: point.y)
        let actual = point.label
        
        // Store old weights for comparison
        let oldWeights = (w1: w1, w2: w2, bias: bias)
        
        var wasError = false
        var newWeights = oldWeights
        
        // If prediction is wrong, update weights
        if prediction != actual {
            wasError = true
            
            // Perceptron weight update rule
            let error = Double(actual - prediction)
            w1 += learningRate * error * point.x
            w2 += learningRate * error * point.y
            bias += learningRate * error
            
            newWeights = (w1: w1, w2: w2, bias: bias)
        }
        
        // Calculate current total errors across all data points
        let totalErrors = dataPoints.reduce(0) { count, dataPoint in
            let pred = predict(x1: dataPoint.x, x2: dataPoint.y)
            return count + (pred != dataPoint.label ? 1 : 0)
        }
        
        currentStep += 1
        currentPointIndex += 1
        
        // Record this step with detailed information
        trainingErrors.append(TrainingError(
            step: currentStep,
            errors: totalErrors,
            wasError: wasError,
            currentPoint: point,
            prediction: prediction,
            actualLabel: actual,
            oldWeights: oldWeights,
            newWeights: newWeights,
            learningRate: learningRate
        ))
        
        // Stop if we've achieved perfect classification
        if totalErrors == 0 {
            isTraining = false
        }
    }
    
    func resetTraining() {
        isTraining = false
        currentEpoch = 0
        currentStep = 0
        currentPointIndex = 0
        trainingErrors = []
        shuffledPoints = []
        
        // Reset to initial parameters based on dataset
        initializePerceptronParameters()
    }
    
    var inputPoint: (x: Double, y: Double)? {
        guard let x1 = Double(inputX1), let x2 = Double(inputX2) else {
            return nil
        }
        return (x: x1, y: x2)
    }
}