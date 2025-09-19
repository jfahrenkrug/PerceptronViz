# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

- **Build**: `xcodebuild -scheme PerceptronViz -configuration Debug build`
- **Run**: Open `PerceptronViz.xcodeproj` in Xcode and press ⌘R
- **Requirements**: macOS 14.0+, Xcode 16+, Swift 6

## Architecture Overview

This is a SwiftUI macOS application that demonstrates perceptron binary classification for educational purposes. The architecture follows the MVVM pattern with SwiftUI's `@Observable` model.

### Core Components

**PerceptronModel** (`PerceptronModel.swift`)
- Main business logic using `@Observable @MainActor`
- Manages perceptron weights (w1, w2, bias), training state, and datasets
- Implements training algorithm with step-by-step visualization
- Handles CSV parsing with automatic header detection
- Provides 4 built-in datasets: AND Gate, OR Gate, Iris Flowers, UIKit vs SwiftUI

**ContentView & Feature Views**
- `ContentView.swift` now focuses solely on owning the `PerceptronModel` state and composing the major panels.
- `TrainingDataEditorView.swift` encapsulates the CSV editor, dataset picker, and parse actions.
- `VisualizationPanelView.swift` coordinates the chart, legend, and control stack via dedicated subviews (`PerceptronChartView`, `ClassificationLegendView`, `PerceptronControlsView`).
- `TrainingAreaView.swift` handles the optional training dashboard and delegates to further focused views (`TrainingProgressChartView`, `TrainingDataTableView`, `StepCalculationDetailsView`, `TrainingControlsPanel`).
- All view files use SwiftUI's `@Bindable` bindings so child views can mutate the shared `PerceptronModel` without duplicating state wiring.

**Data Structures & Utilities**
- `DataPoint.swift`: Core data structures (`DataPoint`, `TrainingError`) with rich metadata for visualizations.
- `SafeCollectionAccess.swift`: Adds a guarded array subscript used by table views to avoid index crashes during training updates.

### Key UI Features

**Educational Training Visualization**
- Horizontal layout during training: Chart | Table | Details | Controls
- Real-time step highlighting in data points table showing current training point
- Detailed calculation breakdown showing weight update formulas: `old + (rate × err × inp) = new`
- Anti-jump layout with fixed frame constraints to prevent UI shifting

**Interactive Controls**
- Weight sliders (W1, W2) and bias with 0.1 precision steps
- Live decision boundary equation display
- CSV text editor with smart header detection
- Test classification with +/- buttons for precise input adjustment

**Chart Management**  
- Auto-scaling charts that fit each dataset perfectly
- Decision boundary line properly clipped to chart bounds
- Dynamic axis labels based on CSV headers
- Double-tap or Reset View button to recalculate chart bounds

### Training Implementation

The training algorithm implements proper epoch-based perceptron learning:
- **Epoch-based convergence**: Training only stops after completing full epochs with zero errors
- **Real-time error tracking**: Uses `currentEpochErrorCount` and `epochHadErrors` flags for accurate progress
- **Dual training modes**: Automatic continuous training and manual step-by-step with identical behavior
- **Convergence protection**: `hasConverged` flag prevents chart updates after training completion
- **Progress visualization**: Shows "Epoch X - Step Y/Z" format with epoch-level error charts
- **Weight update timing**: Calculates errors before weight updates to prevent artificial error spikes
- **Data shuffling**: Randomizes order each epoch while maintaining deterministic step-by-step replay
- **Educational display**: Tracks detailed step information including old/new weights and calculations

### Development Notes

**Custom Table Implementation**
- Uses custom ScrollView-based table for data points display with superior visual design
- Manual header row with consistent styling and proper alignment
- Current step highlighting with yellow background and orange border applied to entire rows
- Monospaced fonts for numeric columns ensure perfect alignment

**CSV Format Support**
- Flexible format: `header1,header2,classification,display_label` or data-only
- Automatic header detection for meaningful axis labels
- Fourth column provides human-readable labels (e.g., "Setosa", "UIKit")
- Built-in datasets demonstrate different classification scenarios

**UI Layout Constraints**
- Training area: Chart (maxWidth: .infinity) | Table (200px) | Details (500px) | Controls (250px)
- Fixed heights (280px chart, 322px details/table) prevent layout jumping
- Progress labels positioned below chart in horizontal layout for better readability
- Monospaced fonts ensure proper alignment in mathematical expressions

**Training Algorithm Correctness**
- **Critical Bug Fixes Applied**: Fixed epoch completion logic, error calculation timing, and manual/auto mode consistency
- **Epoch-based Learning**: Proper ML training pattern where convergence is only checked after full epoch completion
- **Error Calculation**: Errors counted during epoch processing, not recalculated afterward to prevent meaningless epoch concept
- **Chart Synchronization**: Training progress chart updates only at epoch boundaries, showing meaningful error reduction trends
- **Manual Stepping Consistency**: Manual step button produces identical results to automatic training, including post-convergence behavior
