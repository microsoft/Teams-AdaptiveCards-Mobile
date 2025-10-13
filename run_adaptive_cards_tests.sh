#!/bin/bash
#
# Adaptive Cards Test Runner - SDK & Visualizer Tests
# Usage: ./run_adaptive_cards_tests.sh [mode] [test_name]
# 
# Modes:
#   sdk        - Run AdaptiveCards framework unit tests (default)
#   visualizer - Run ADCIOSVisualizer UI tests
#   app|run    - Build and launch ADCIOSVisualizer app in simulator
#   all        - Run both SDK and Visualizer tests
#
# Examples:
#   ./run_adaptive_cards_tests.sh                                    # Run all SDK tests
#   ./run_adaptive_cards_tests.sh sdk                                # Run all SDK tests
#   ./run_adaptive_cards_tests.sh sdk testKVOObserver                # Run specific SDK test
#   ./run_adaptive_cards_tests.sh visualizer                         # Run all Visualizer tests
#   ./run_adaptive_cards_tests.sh visualizer testOpenAIApp           # Run specific Visualizer test
#   ./run_adaptive_cards_tests.sh app                                # Launch visualizer app in simulator
#   ./run_adaptive_cards_tests.sh run                                # Same as 'app'
#   ./run_adaptive_cards_tests.sh all                                # Run everything
#
# Configuration:
#   Edit DEVICE and IOS_VERSION below to match your simulator setup
#   Edit kAutoLoadCard in AdaptiveFileBrowserSource.mm to auto-load a specific card
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# OPENAI APPS TESTING WORKFLOW
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Quick Test Workflow:
# 1. Set test JSON in Visualizer: Edit ADCIOSVisualizerUITests.m to set TEST_JSON_NAME
# 2. Run tests: ./run_adaptive_cards_tests.sh visualizer
# 3. Check output for compilation/runtime errors
# 4. Fix issues and iterate
#
# Common Issues:
# - Binding conflicts: Use @SwiftUI.Binding instead of Binding in SwiftUI views
# - Missing imports: Add WebKit import to files using WKWebView
# - Module not found: Clean build folder with: rm -rf ~/Library/Developer/Xcode/DerivedData
#
# Debug Commands:
#   List simulators:  xcrun simctl list devices
#   Clean build:      xcodebuild clean -scheme AdaptiveCards
#   Build only:       xcodebuild build -scheme AdaptiveCards -destination '...'
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DEVICE="iPhone 16"
IOS_VERSION="18.6"
DESTINATION="platform=iOS Simulator,name=${DEVICE},OS=${IOS_VERSION}"

# Paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORKSPACE="${SCRIPT_DIR}/source/ios/AdaptiveCards/AdaptiveCards.xcworkspace"
SDK_PROJECT="${SCRIPT_DIR}/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards.xcodeproj"
VISUALIZER_PROJECT="${SCRIPT_DIR}/source/ios/AdaptiveCards/ADCIOSVisualizer/ADCIOSVisualizer.xcodeproj"

# Schemes
SDK_SCHEME="AdaptiveCards"
VISUALIZER_SCHEME="ADCIOSVisualizer"

# Test targets
SDK_TEST_TARGET="AdaptiveCardsTests/AdaptiveCardsTests"
VISUALIZER_TEST_TARGET="ADCIOSVisualizerUITests"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_config() {
    echo -e "${YELLOW}Configuration:${NC}"
    echo -e "  Device:      ${CYAN}$DEVICE${NC}"
    echo -e "  iOS Version: ${CYAN}$IOS_VERSION${NC}"
    echo -e "  Mode:        ${CYAN}$MODE${NC}"
    if [ -n "$SPECIFIC_TEST" ]; then
        echo -e "  Test:        ${CYAN}$SPECIFIC_TEST${NC}"
    fi
    echo ""
}

run_sdk_tests() {
    local test_name="${1:-}"
    
    print_header "🧪 Running AdaptiveCards SDK Tests"
    print_config
    
    local test_args=""
    if [ -n "$test_name" ]; then
        test_args="-only-testing:${SDK_TEST_TARGET}/${test_name}"
        echo -e "${CYAN}Running specific test: ${test_name}${NC}"
    else
        echo -e "${CYAN}Running all SDK tests${NC}"
    fi
    echo ""
    
    # Create temp file for output
    local temp_log=$(mktemp)
    trap "rm -f $temp_log" EXIT
    
    echo -e "${BLUE}🔨 Building and testing SDK...${NC}"
    echo ""
    
    if [ -n "$test_args" ]; then
        xcodebuild test \
            -project "$SDK_PROJECT" \
            -scheme "$SDK_SCHEME" \
            -destination "$DESTINATION" \
            $test_args \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Suite|Test Case|passed|failed|error:|warning:|Executed|^$|✅|❌)"
    else
        xcodebuild test \
            -project "$SDK_PROJECT" \
            -scheme "$SDK_SCHEME" \
            -destination "$DESTINATION" \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Suite|Test Case|passed|failed|error:|warning:|Executed|^$|✅|❌)"
    fi
    
    if [ $? -eq 0 ]; then
        
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ SDK TESTS PASSED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Show summary
        echo ""
        echo -e "${BLUE}📊 Summary:${NC}"
        grep -E "Test Suite.*passed|Executed.*tests" "$temp_log" | tail -3
        
        return 0
    else
        local exit_code=$?
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ SDK TESTS FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Show failures
        echo ""
        echo -e "${RED}Failed Tests:${NC}"
        grep -E "Test Case.*failed|error:" "$temp_log" | tail -20
        
        return $exit_code
    fi
}

run_visualizer_tests() {
    local test_name="${1:-}"
    
    print_header "📱 Running ADCIOSVisualizer UI Tests"
    print_config
    
    local test_args=""
    if [ -n "$test_name" ]; then
        test_args="-only-testing:${VISUALIZER_TEST_TARGET}/${test_name}"
        echo -e "${CYAN}Running specific test: ${test_name}${NC}"
    else
        echo -e "${CYAN}Running all Visualizer tests${NC}"
    fi
    echo ""
    
    # Create temp file for output
    local temp_log=$(mktemp)
    trap "rm -f $temp_log" EXIT
    
    echo -e "${BLUE}🔨 Building and testing Visualizer...${NC}"
    echo ""
    
    if [ -n "$test_args" ]; then
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "$VISUALIZER_SCHEME" \
            -destination "$DESTINATION" \
            $test_args \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Case|KVO|OpenAI|PASS|FAIL|error:|warning:|✅|❌|Executed|^$)"
    else
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "$VISUALIZER_SCHEME" \
            -destination "$DESTINATION" \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Case|KVO|OpenAI|PASS|FAIL|error:|warning:|✅|❌|Executed|^$)"
    fi
    
    if [ $? -eq 0 ]; then
        
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ VISUALIZER TESTS PASSED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Show summary
        echo ""
        echo -e "${BLUE}📊 Summary:${NC}"
        grep -E "Test Suite.*passed|Executed.*tests" "$temp_log" | tail -3
        
        return 0
    else
        local exit_code=$?
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ VISUALIZER TESTS FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        # Check for compile errors
        if grep -q "error:" "$temp_log"; then
            echo ""
            echo -e "${YELLOW}🔧 Compilation Errors:${NC}"
            grep "error:" "$temp_log" | tail -10
        fi
        
        # Show test failures
        echo ""
        echo -e "${RED}Test Failures:${NC}"
        grep -E "Test Case.*failed|assertion failed" "$temp_log" | tail -20
        
        return $exit_code
    fi
}

run_visualizer_app() {
    print_header "🚀 Launching ADCIOSVisualizer App"
    print_config
    
    echo -e "${CYAN}Building and launching app in simulator...${NC}"
    echo ""
    
    # Create temp file for output
    local temp_log=$(mktemp)
    trap "rm -f $temp_log" EXIT
    
    echo -e "${BLUE}🔨 Building ADCIOSVisualizer (includes AdaptiveCards dependency)...${NC}"
    echo ""
    
    # Build using workspace (auto-handles dependencies)
    xcodebuild build \
        -workspace "$WORKSPACE" \
        -scheme "$VISUALIZER_SCHEME" \
        -destination "$DESTINATION" \
        2>&1 | tee "$temp_log" | grep -E "(Build succeeded|Building|error:)" | tail -15
    
    if [ $? -ne 0 ] || grep -q "error:" "$temp_log"; then
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ BUILD FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        grep "error:" "$temp_log" | tail -10
        return 1
    fi
    
    echo ""
    echo -e "${GREEN}✅ Build succeeded${NC}"
    echo ""
    
    # Find the app bundle (exclude Index.noindex, look in Build/Products)
    local app_path=$(find "$HOME/Library/Developer/Xcode/DerivedData" -path "*/Build/Products/*" -name "ADCIOSVisualizer.app" -type d | grep -v "Index.noindex" | head -1)
    
    if [ -z "$app_path" ]; then
        echo -e "${RED}❌ Could not find ADCIOSVisualizer.app${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📱 Installing app: $app_path${NC}"
    echo ""
    
    # Get the simulator ID
    local simulator_id=$(xcrun simctl list devices available | grep "iPhone 16 (.*) (Booted)" | grep -o '[A-F0-9-]\{36\}' | head -1)
    
    if [ -z "$simulator_id" ]; then
        echo -e "${YELLOW}Starting iPhone 16 simulator...${NC}"
        xcrun simctl boot "iPhone 16" 2>/dev/null
        sleep 3
        simulator_id=$(xcrun simctl list devices available | grep "iPhone 16" | grep -o '[A-F0-9-]\{36\}' | head -1)
    fi
    
    echo -e "${BLUE}Simulator ID: $simulator_id${NC}"
    echo ""
    
    # Install the app
    echo -e "${BLUE}📲 Installing app on simulator...${NC}"
    xcrun simctl install "$simulator_id" "$app_path"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install app${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ App installed${NC}"
    echo ""
    
    # Get the actual bundle identifier from Info.plist
    local bundle_id=$(plutil -extract CFBundleIdentifier raw "$app_path/Info.plist")
    echo -e "${BLUE}Bundle ID: $bundle_id${NC}"
    echo ""
    
    # Launch the app
    echo -e "${BLUE}🚀 Launching app...${NC}"
    xcrun simctl launch "$simulator_id" "$bundle_id"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ APP LAUNCHED SUCCESSFULLY${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${CYAN}📝 Auto-loading: samples/OpenAIAppSamples/figma-textblock.json${NC}"
        echo -e "${CYAN}   (configured in AdaptiveFileBrowserSource.mm)${NC}"
        echo ""
        echo -e "${BLUE}📊 Diagnostic Logs:${NC}"
        echo -e "   Directory: ~/Library/Developer/CoreSimulator/Devices/$simulator_id/data/Containers/Data/Application/*/Library/Application Support/AdaptiveCardsLogs/"
        echo -e "   Files:     adaptivecards_session_*.log"
        echo -e "   Usage:     ACDiagnosticLogger.log(\"message\", category: \"OpenAIApp\")"
        echo ""
        echo -e "${BLUE}To change the auto-load card:${NC}"
        echo -e "   Edit: source/ios/AdaptiveCards/ADCIOSVisualizer/ADCIOSVisualizer/AdaptiveFileBrowserSource.mm"
        echo -e "   Line: static NSString *const kAutoLoadCard = @\"...\""
        echo ""
        return 0
    else
        echo ""
        echo -e "${RED}❌ Failed to launch app${NC}"
        return 1
    fi
}

# Parse arguments
MODE="${1:-sdk}"
SPECIFIC_TEST="${2:-}"

case "$MODE" in
    sdk)
        run_sdk_tests "$SPECIFIC_TEST"
        exit $?
        ;;
    visualizer)
        run_visualizer_tests "$SPECIFIC_TEST"
        exit $?
        ;;
    app|run)
        run_visualizer_app
        exit $?
        ;;
    all)
        echo -e "${CYAN}Running all tests (SDK + Visualizer)${NC}"
        echo ""
        
        sdk_passed=true
        visualizer_passed=true
        
        if ! run_sdk_tests; then
            sdk_passed=false
        fi
        
        echo ""
        echo ""
        
        if ! run_visualizer_tests; then
            visualizer_passed=false
        fi
        
        echo ""
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BLUE}   Final Results${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        if $sdk_passed; then
            echo -e "  SDK Tests:        ${GREEN}✅ PASSED${NC}"
        else
            echo -e "  SDK Tests:        ${RED}❌ FAILED${NC}"
        fi
        
        if $visualizer_passed; then
            echo -e "  Visualizer Tests: ${GREEN}✅ PASSED${NC}"
        else
            echo -e "  Visualizer Tests: ${RED}❌ FAILED${NC}"
        fi
        
        echo ""
        
        if $sdk_passed && $visualizer_passed; then
            echo -e "${GREEN}🎉 All tests passed!${NC}"
            exit 0
        else
            echo -e "${RED}💔 Some tests failed${NC}"
            exit 1
        fi
        ;;
    help|--help|-h)
        print_header "Adaptive Cards Test Runner Help"
        echo "Usage: $0 [mode] [test_name]"
        echo ""
        echo "Modes:"
        echo "  sdk        - Run AdaptiveCards framework unit tests (default)"
        echo "  visualizer - Run ADCIOSVisualizer UI tests"
        echo "  all        - Run both SDK and Visualizer tests"
        echo ""
        echo "Examples:"
        echo "  $0                                  # Run SDK tests"
        echo "  $0 sdk                              # Run SDK tests"
        echo "  $0 sdk testKVOObserver              # Run specific SDK test"
        echo "  $0 visualizer                       # Run Visualizer tests"
        echo "  $0 visualizer testOpenAIApp         # Run specific Visualizer test"
        echo "  $0 all                              # Run everything"
        echo ""
        echo "Configuration:"
        echo "  Device:      $DEVICE"
        echo "  iOS Version: $IOS_VERSION"
        echo ""
        exit 0
        ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
