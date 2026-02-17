# Visual Parity Bridge

Shared infrastructure for **visual parity testing** between the legacy
(ObjC/C++ + UIKit) and greenfield (SwiftUI) Adaptive Cards iOS renderers.

## Overview

The visual parity bridge ensures the greenfield SwiftUI renderer produces
output that converges toward the legacy ObjC/C++ renderer over time. It uses
a **golden-path baseline** approach:

1. Legacy renders a set of canonical cards → golden PNG baselines
2. Greenfield renders the same cards → greenfield regression baselines
3. Cross-renderer pixel diff reports track convergence (informational, non-blocking)

## Structure

```
shared/
├── parity-cards/                # Canonical JSON card definitions (12 cards)
│   ├── parity-textblock-basic.json
│   ├── parity-image-sizes.json
│   ├── parity-container-styles.json
│   ├── parity-columnset-layouts.json
│   ├── parity-factset.json
│   ├── parity-imageset.json
│   ├── parity-actions.json
│   ├── parity-richtext.json
│   ├── parity-table.json
│   ├── parity-activity-update.json
│   ├── parity-nested-containers.json
│   └── parity-inputs.json
├── golden-baselines/
│   └── legacy/                  # PNG baselines from ObjC/C++ renderer
│       ├── parity-textblock-basic.png
│       ├── parity-image-sizes.png
│       └── ... (12 PNGs total)
└── README.md                    # This file
```

## Repositories

| Repo | Branch | Role |
|------|--------|------|
| `microsoft/Teams-AdaptiveCards-Mobile` | `feature/hggz/visual-parity-baselines` | Legacy baseline generator |
| `hggz/AdaptiveCards-Mobile-1` | `feature/visual-testing-activation` | Greenfield parity tests |

## How It Works

### Legacy Baseline Generation (this repo)

The parity baseline generator is the `ACRParityBaselineTests` class, integrated
into `ADCIOSVisualizerTests.mm` (no separate file or pbxproj changes needed).

It renders each parity card via `ACRRenderer` at 393pt width (iPhone 15 Pro
equivalent) with `ACRThemeLight` and saves 2x PNG snapshots.

**To regenerate baselines:**
1. Open `AdaptiveCards.xcworkspace` in Xcode
2. Select an iPhone simulator
3. Run `ACRParityBaselineTests/testGenerateAllParityBaselines`
4. PNGs appear in `shared/golden-baselines/legacy/`

Or run individual tests: `testBaseline_textblockBasic`, `testBaseline_actions`, etc.

### Greenfield Parity Comparison (greenfield repo)

`LegacyParityTests.swift` in the greenfield repo performs two checks per card:

1. **Greenfield regression** (assertive, 1% tolerance) — catches SwiftUI render
   regressions between greenfield commits
2. **Cross-renderer parity** (reporting-only) — computes pixel diff against
   legacy golden baselines, generates diff images and a JSON report

The cross-renderer comparison is **intentionally non-failing** because the two
renderers (UIKit/ObjC vs SwiftUI) produce structurally different output.
Initial diffs are 60–92% and will decrease as the greenfield renderer matures.

**To run greenfield tests:**
```bash
cd ios
xcodebuild test -scheme AdaptiveCards-Package \
  -destination 'platform=iOS Simulator,name=iPhone 16e' \
  -only-testing:VisualTests/LegacyParityTests \
  CODE_SIGNING_ALLOWED=NO
```

**To record new greenfield baselines** (after greenfield render changes):
```bash
touch ios/Tests/VisualTests/Snapshots/.record
# Run tests (same command as above)
rm ios/Tests/VisualTests/Snapshots/.record
```

## Adding New Parity Cards

1. Create a JSON in `parity-cards/` named `parity-<element>.json`
2. Add a test method in `ACRParityBaselineTests` (in `ADCIOSVisualizerTests.mm`):
   ```objc
   - (void)testBaseline_newElement {
       [self generateBaseline:@"parity-new-element"];
   }
   ```
3. Run `testGenerateAllParityBaselines` to generate the legacy PNG
4. Copy `shared/` changes to the greenfield repo
5. Add a matching test in `LegacyParityTests.swift`:
   ```swift
   func testParity_newElement() {
       assertLegacyParity(cardName: "parity-new-element")
   }
   ```
6. Record greenfield baselines (touch `.record`, run tests, remove `.record`)

## Parity Baseline (February 2026)

| Card | Diff % | Notes |
|------|--------|-------|
| table | 60.5% | Best — closest structural match |
| inputs | 63.7% | Input controls differ in chrome |
| textblock-basic | 68.0% | Font rendering engine differences |
| image-sizes | 78.0% | Image layout/sizing logic |
| imageset | 78.4% | Grid layout differences |
| factset | 78.7% | Label alignment and spacing |
| actions | 79.8% | Button styling |
| richtext | 79.1% | Inline text attribute rendering |
| activity-update | 80.0% | Composite card |
| columnset-layouts | 80.9% | Column width calculations |
| nested-containers | 90.3% | Deep nesting + background styles |
| container-styles | 92.2% | Background color/padding differences |
| **Average** | **77.5%** | |

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
