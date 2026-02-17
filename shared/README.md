# Visual Parity Baselines

This directory contains the shared infrastructure for visual parity testing
between the **legacy** (ObjC/C++) and **greenfield** (SwiftUI) Adaptive Cards
renderers.

## Structure

```
shared/
├── parity-cards/           # Canonical JSON card definitions (shared input)
│   ├── parity-textblock-basic.json
│   ├── parity-image-sizes.json
│   ├── parity-container-styles.json
│   ├── parity-columnset-layouts.json
│   ├── parity-factset.json
│   ├── parity-imageset.json
│   ├── parity-actions.json
│   ├── parity-richtext.json
│   ├── parity-table.json
│   ├── parity-activity-update.json   # Composed card (TextBlock + ColumnSet + FactSet + Actions)
│   ├── parity-nested-containers.json # Deep nesting with mixed styles
│   └── parity-inputs.json            # Input controls (Text, Number, Date, Toggle, ChoiceSet)
├── golden-baselines/
│   └── legacy/             # PNG baselines rendered by the legacy ObjC/C++ renderer
│       ├── parity-textblock-basic.png
│       ├── parity-image-sizes.png
│       └── ...
└── README.md               # This file
```

## How It Works

### Phase 1: Shared Parity Cards
Each JSON file in `parity-cards/` is a minimal Adaptive Card that exercises a
single element type or layout pattern. Both renderers parse and render the same
JSON, ensuring the comparison is apples-to-apples.

### Phase 2: Legacy Baseline Generation
The test file `ACRParityBaselineTests.mm` (in `ADCIOSVisualizerTests`) renders
each parity card via the legacy `ACRRenderer` at 393pt width (iPhone 15 Pro)
and saves 2x PNG snapshots to `golden-baselines/legacy/`.

**To generate baselines:**
1. Open `AdaptiveCards.xcworkspace` in Xcode
2. Add `ACRParityBaselineTests.mm` to the `ADCIOSVisualizerTests` target
3. Run the test `testGenerateAllParityBaselines` on an iPhone simulator
4. PNGs appear in `shared/golden-baselines/legacy/`

### Phase 3: Greenfield Parity Comparison
The greenfield project (`hggz/AdaptiveCards-Mobile` fork) contains
`LegacyParityTests.swift` which:
1. Loads the same parity card JSONs
2. Renders via `AdaptiveCardView` (SwiftUI)
3. Compares the output against the legacy golden-baseline PNGs
4. Uses a relaxed tolerance (5-10%) to account for font rendering
   and layout engine differences between UIKit and SwiftUI

## Adding New Parity Cards

1. Create a new JSON in `parity-cards/` following the naming convention
   `parity-<element-or-pattern>.json`
2. Add an individual test method in `ACRParityBaselineTests.mm`
3. Re-run `testGenerateAllParityBaselines` to regenerate baselines
4. Copy the new card and baseline to the greenfield project
5. Add matching test in `LegacyParityTests.swift`

## Card Coverage

| Card | Elements Tested |
|------|----------------|
| textblock-basic | TextBlock sizes, weights, colors, alignment, maxLines |
| image-sizes | Image small, medium, large, centered |
| container-styles | Container Default, Emphasis, Good, Warning, Attention |
| columnset-layouts | ColumnSet equal, auto+stretch, weighted |
| factset | FactSet with 5 key-value pairs |
| imageset | ImageSet with 3 medium images |
| actions | Action.Submit, Action.OpenUrl, Action.ShowCard |
| richtext | RichTextBlock with bold, italic, color, strikethrough |
| table | Table with header row, 3 columns, 2 data rows |
| activity-update | Composed: TextBlock + ColumnSet + FactSet + ShowCard |
| nested-containers | Container/Column nesting with mixed styles |
| inputs | Input.Text, Number, Date, Time, Toggle, ChoiceSet |
