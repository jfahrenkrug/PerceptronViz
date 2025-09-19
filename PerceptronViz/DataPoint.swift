//
//  DataPoint.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import Foundation

/// Represents a single training example with coordinates and classification label.
struct DataPoint: Identifiable, Hashable {
    let id = UUID()
    let x: Double
    let y: Double
    let label: Int
    
    init(x: Double, y: Double, label: Int) {
        self.x = x
        self.y = y
        self.label = label
    }
}

/// Captures the outcome and calculations for one perceptron training step.
struct TrainingError: Identifiable {
    let id = UUID()
    let step: Int
    let errors: Int
    let wasError: Bool
    let currentPoint: DataPoint?
    let prediction: Int?
    let actualLabel: Int?
    let oldWeights: (w1: Double, w2: Double, bias: Double)?
    let newWeights: (w1: Double, w2: Double, bias: Double)?
    let learningRate: Double?
}
