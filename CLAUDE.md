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

**ContentView** (`ContentView.swift`) 
- Main UI with horizontal layout: left panel (data input) | right panel (visualization + controls)
- Training area toggles to show: training chart | data points table | calculation details | controls
- Uses SwiftUI Charts for real-time decision boundary visualization
- Interactive sliders for weight adjustment with live equation updates

**DataPoint** (`DataPoint.swift`)
- Core data structures: `DataPoint` and `TrainingError`
- TrainingError captures detailed step information for educational display

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

The training algorithm implements the perceptron learning rule:
- Shuffles data points each epoch for better convergence
- Tracks detailed step information including old/new weights
- Supports configurable learning rate, max epochs, and pause duration
- Visual progress tracking with error count charts
- Step-by-step mode and continuous training modes

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
- Monospaced fonts ensure proper alignment in mathematical expressions