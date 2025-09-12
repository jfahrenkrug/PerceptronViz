import Foundation

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