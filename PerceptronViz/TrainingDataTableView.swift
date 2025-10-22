//
//  TrainingDataTableView.swift
//  PerceptronViz
//
//  Created by Johannes Fahrenkrug on 18.09.25.
//  https://springenwerk.com
//

import SwiftUI

/// Lists training samples and highlights the current point under evaluation.
struct TrainingDataTableView: View {
    let dataPoints: [DataPoint]
    let xAxisLabel: String
    let yAxisLabel: String
    let lastTrainingStep: TrainingError?
    let colorProvider: (Int) -> Color
    
    private let headerFontSize: CGFloat = 18
    private let valueFontSize: CGFloat = 16
    
    private var headerFont: Font { .system(size: headerFontSize, weight: .semibold) }
    private var valueFont: Font { .system(size: valueFontSize) }
    
    private var indexedDataPoints: [IndexedDataPoint] {
        dataPoints.enumerated().map { index, point in
            IndexedDataPoint(id: point.id, index: index + 1, point: point)
        }
    }
    
    private var highlightedRowID: DataPoint.ID? {
        lastTrainingStep?.currentPoint?.id
    }
    
    var body: some View {
        Table(indexedDataPoints) {
            TableColumn("#") { row in
                tableCell(for: row, text: "\(row.index)")
            }
            .width(min: 32, ideal: 40, max: 60)
            .alignment(.trailing)
            
            TableColumn(xAxisLabel) { row in
                tableCell(for: row, text: formattedValue(row.point.x), monospaced: true)
            }
            .width(min: 32, ideal: 60, max: 110)
            .alignment(.trailing)
            
            TableColumn(yAxisLabel) { row in
                tableCell(for: row, text: formattedValue(row.point.y), monospaced: true)
            }
            .width(min: 32, ideal: 60, max: 110)
            .alignment(.trailing)
            
            TableColumn("Label") { row in
                tableCell(
                    for: row,
                    text: "\(row.point.label)",
                    textColor: colorProvider(row.point.label)
                )
            }
            .width(min: 48, ideal: 60, max: 90)
            .alignment(.trailing)
        }
        .tableStyle(.inset(alternatesRowBackgrounds: false))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .font(headerFont)
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func formattedValue(_ value: Double) -> String {
        String(format: "%.1f", value)
    }
    
    @ViewBuilder
    private func tableCell(for entry: IndexedDataPoint, text: String, monospaced: Bool = false, textColor: Color? = nil) -> some View {
        let isHighlighted = highlightedRowID == entry.id
        let font: Font = monospaced ? .system(size: valueFontSize, weight: .regular, design: .monospaced) : valueFont
        let background = RoundedRectangle(cornerRadius: 6)
            .fill(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
        let border = RoundedRectangle(cornerRadius: 6)
            .stroke(isHighlighted ? Color.orange : Color.clear, lineWidth: 1)
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            Text(text)
                .font(font)
                .foregroundColor(textColor ?? .primary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 6)
        .background(background)
        .overlay(border)
    }
    
    private struct IndexedDataPoint: Identifiable {
        let id: DataPoint.ID
        let index: Int
        let point: DataPoint
    }
}
