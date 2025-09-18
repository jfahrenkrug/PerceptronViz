# Perceptron Visualizer

A SwiftUI macOS application that demonstrates how a perceptron works for binary classification. Perfect for educational purposes and conference demos!

Note: The initial version of this app was entirely vibe coded using Claude Code. I didn't write a single line of code by hand.

## Features

### 🎯 Interactive Perceptron Visualization
- **Real-time decision boundary**: Watch the linear separator update as you adjust weights and bias
- **Smart chart scaling**: Automatically fits each dataset perfectly, no jarring scale jumps
- **Properly clipped decision line**: Boundary line stays within chart bounds
- **Dynamic labeling**: Axis labels, legends, and equations automatically update based on CSV headers
- **Self-documenting charts**: Each dataset shows its own meaningful labels (e.g., "Sepal Length" vs "Sepal Width")

### 📊 Multiple Dataset Options
Choose from preset datasets via the dropdown menu:

1. **AND Gate** - Classic boolean logic gate
2. **OR Gate** - Another fundamental logic gate  
3. **Iris Flowers** - Setosa vs Versicolor classification (sepal dimensions)
4. **UIKit vs SwiftUI** - Humorous developer dataset comparing:
   - X-axis: Development time (hours) 
   - Y-axis: Number of bugs
   - Labels: UIKit (slower development, fewer bugs) vs SwiftUI (faster development, more bugs)

### 🎛️ Precision Controls
- **Weight sliders (W1, W2)**: Range -10 to +10 with 0.1 step precision
- **Bias slider**: Range -10 to +10 with 0.1 step precision
- **Snap-to values**: All sliders snap to 0.1 increments for precise control
- **Live equation display**: Shows the current decision boundary equation

### 📝 Data Input & View Controls
- **CSV text editor**: Paste your own training data
- **Smart header detection**: First line can contain column headers for automatic labeling
- **Flexible format**: `header1,header2,output_label` or just data rows
- **Parse button**: Load your custom dataset  
- **Real-time feedback**: Shows number of parsed data points
- **Reset View button**: Instantly fit the chart to show all data points
- **Double-tap chart**: Alternative way to reset the view to fit data

## Technical Details

- **Built with Swift 6**: Full concurrency compliance, no warnings
- **Native SwiftUI Charts**: Uses built-in Charts framework for optimal performance
- **macOS Application**: Designed specifically for macOS with proper window management
- **Educational Focus**: Clear visualizations and interactive controls for learning

## Usage

1. **Select a dataset** from the dropdown menu
2. **Adjust the weights** (W1, W2) using the sliders
3. **Modify the bias** to see how it shifts the decision boundary
4. **Observe** how the green line separates the two classes of data points
5. **Experiment** with your own CSV data by pasting it in the text area

## Mathematical Foundation

The perceptron implements a linear decision boundary defined by:
```
W1 × x₁ + W2 × x₂ + bias = 0
```

Points above the line are classified as one class, points below as another.

## Building and Running

1. Open `PerceptronViz.xcodeproj` in Xcode
2. Build and run (⌘R)
3. Requires macOS 14.0+ and Xcode 16+

## Perfect for Conferences

The **UIKit vs SwiftUI** dataset is specifically designed as a humorous talking point for iOS developer conferences, playfully highlighting the trade-offs between development speed and bug frequency in different UI frameworks.

---

*Built with ❤️ using SwiftUI and Swift Charts*