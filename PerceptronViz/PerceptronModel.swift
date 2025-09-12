import Foundation
import SwiftUI

@Observable
class PerceptronModel {
    var csvText: String = ""
    var dataPoints: [DataPoint] = []
    var w1: Double = 1.0
    var w2: Double = 1.0
    var bias: Double = 0.0
    
    func parseCSV() {
        let lines = csvText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var newDataPoints: [DataPoint] = []
        
        for line in lines {
            let components = line.components(separatedBy: ",")
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
    }
    
    func decisionBoundaryLine(in xRange: ClosedRange<Double>) -> (start: (x: Double, y: Double), end: (x: Double, y: Double))? {
        guard w2 != 0 else { return nil }
        
        let startX = xRange.lowerBound
        let endX = xRange.upperBound
        
        let startY = -(w1 * startX + bias) / w2
        let endY = -(w1 * endX + bias) / w2
        
        return (start: (x: startX, y: startY), end: (x: endX, y: endY))
    }
}