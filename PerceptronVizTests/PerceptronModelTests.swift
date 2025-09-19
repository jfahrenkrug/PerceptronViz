import Testing
@testable import PerceptronViz

@Suite struct PerceptronModelTests {
    @Test @MainActor func parseCSVWithHeadersUpdatesModel() {
        let model = PerceptronModel()
        model.csvText = """
        XCoord,YCoord,Classification,Label
        0,0,-1,Zero
        1,1,1,One
        """

        model.parseCSV()

        #expect(model.dataPoints.count == 2)
        #expect(model.xAxisLabel == "XCoord")
        #expect(model.yAxisLabel == "YCoord")
        #expect(model.negativeDisplayLabel == "Zero")
        #expect(model.positiveDisplayLabel == "One")
    }

    @Test @MainActor func predictUsesCurrentWeightsAndBias() {
        let model = PerceptronModel()
        model.w1 = 2
        model.w2 = 1
        model.bias = -1

        #expect(model.predict(x1: 1, x2: 0.5) == 1)
        #expect(model.predict(x1: -0.2, x2: -0.1) == -1)
    }

    @Test @MainActor func decisionBoundaryProjectsWithinChartRange() {
        let model = PerceptronModel()
        model.w1 = 1
        model.w2 = -1
        model.bias = 0

        let boundary = model.decisionBoundaryLine(in: 0...1, yRange: 0...1)
        #expect(boundary?.count == 2)
        #expect(boundary?.contains { abs($0.x) < 0.001 && abs($0.y) < 0.001 } == true)
        #expect(boundary?.contains { abs($0.x - 1) < 0.001 && abs($0.y - 1) < 0.001 } == true)
    }
}
