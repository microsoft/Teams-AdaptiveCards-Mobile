#!/bin/bash

# This script adds the Swift bridge files to the AdaptiveCards Xcode project
echo "Adding Swift bridge files to AdaptiveCards project..."

cd "/Users/hugogonzalez/Documents/code/work/microsoft/AdaptiveCards-Mobile/source/ios/AdaptiveCards/AdaptiveCards"

# Build the project to ensure it's properly loaded
xcodebuild -project AdaptiveCards.xcodeproj -target AdaptiveCards -configuration Debug build

echo "Files have been added to the project. Please open the AdaptiveCards.xcodeproj and verify the files are included."
echo "If the files are not included, you may need to manually add them in Xcode:"
echo "1. Open AdaptiveCards.xcodeproj in Xcode"
echo "2. Right-click on the AdaptiveCards group in the Project Navigator"
echo "3. Select 'Add Files to AdaptiveCards...'"
echo "4. Navigate to the AdaptiveCards folder and select these files:"
echo "   - SwiftAdaptiveCardParser.h"
echo "   - SwiftAdaptiveCardParser.m"
echo "   - SwiftAdaptiveCardParseResult.h"
echo "   - SwiftAdaptiveCardParseResult.m"
echo "   - ACRParseWarning+Swift.h"
echo "   - ACRParseWarning+Swift.mm"
echo "   - SwiftAdaptiveCardObjcBridge.h"
echo "   - SwiftAdaptiveCardObjcBridge.mm"
echo "5. Ensure 'Create groups' is selected"
echo "6. Click 'Add'"
echo "7. Build the project"
