#!/bin/bash
#
# Adaptive Cards Test Runner with Screenshot Capture
# Usage: ./run_adaptive_cards_tests_with_screenshots.sh [mode] [test_name]
# 
# Modes:
#   sdk        - Run AdaptiveCards framework unit tests (no screenshots)
#   visualizer - Run ADCIOSVisualizer UI tests with screenshots
#   all        - Run both SDK and Visualizer tests
#
# Features:
#   - Captures screenshots during UI test execution
#   - Extracts screenshots from xcresult bundle
#   - Organizes screenshots by test case and timestamp
#   - Generates summary report with metadata
#   - Prepares artifacts for CI/CD integration
#
# Examples:
#   ./run_adaptive_cards_tests_with_screenshots.sh visualizer
#   ./run_adaptive_cards_tests_with_screenshots.sh visualizer testPopoverRendering
#   ./run_adaptive_cards_tests_with_screenshots.sh all
#
# Configuration:
#   Edit DEVICE and IOS_VERSION to match your simulator setup
#   Screenshots saved to: screenshots/<timestamp>/
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CONFIGURATION
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DEVICE="iPhone 17"
IOS_VERSION="26.2"
# DESTINATION will be set dynamically based on booted simulator

# Paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Find repo root (go up from scripts/test-utils to repo root)
REPO_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"
WORKSPACE="${REPO_ROOT}/source/ios/AdaptiveCards/AdaptiveCards.xcworkspace"
SDK_PROJECT="${REPO_ROOT}/source/ios/AdaptiveCards/AdaptiveCards/AdaptiveCards.xcodeproj"
VISUALIZER_PROJECT="${REPO_ROOT}/source/ios/AdaptiveCards/ADCIOSVisualizer/ADCIOSVisualizer.xcodeproj"

# Schemes
SDK_SCHEME="AdaptiveCards"
VISUALIZER_SCHEME="ADCIOSVisualizer"

# Test targets
SDK_TEST_TARGET="AdaptiveCardsTests/AdaptiveCardsTests"
VISUALIZER_TEST_TARGET="ADCIOSVisualizerUITests/ADCIOSVisualizerUITests"

# Screenshot configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCREENSHOT_BASE_DIR="${REPO_ROOT}/screenshots"
SCREENSHOT_DIR="${SCREENSHOT_BASE_DIR}/${TIMESTAMP}"
CAPTURE_INTERVAL=1  # Seconds between periodic screenshots (0 = disabled)

# Result bundle path
RESULT_BUNDLE_PATH="${SCREENSHOT_DIR}/TestResults.xcresult"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}   $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_config() {
    echo -e "${YELLOW}Configuration:${NC}"
    echo -e "  Device:           ${CYAN}$DEVICE${NC}"
    echo -e "  iOS Version:      ${CYAN}$IOS_VERSION${NC}"
    echo -e "  Mode:             ${CYAN}$MODE${NC}"
    echo -e "  Screenshot Dir:   ${CYAN}$SCREENSHOT_DIR${NC}"
    if [ -n "$SPECIFIC_TEST" ]; then
        echo -e "  Test:             ${CYAN}$SPECIFIC_TEST${NC}"
    fi
    echo ""
}

setup_screenshot_directory() {
    local mode=$1
    mkdir -p "${SCREENSHOT_DIR}/${mode}"
    echo -e "${GREEN}✓${NC} Created screenshot directory: ${CYAN}${SCREENSHOT_DIR}/${mode}${NC}"
}

get_simulator_id() {
    # Try to get booted simulator first
    local sim_id=$(xcrun simctl list devices available | grep "${DEVICE}.*Booted" | grep -o '[A-F0-9-]\{36\}' | head -1)
    
    if [ -z "$sim_id" ]; then
        # Get any available simulator with matching name
        sim_id=$(xcrun simctl list devices available | grep "${DEVICE}" | grep -o '[A-F0-9-]\{36\}' | head -1)
    fi
    
    echo "$sim_id"
}

boot_simulator() {
    local sim_id=$1
    
    echo -e "${CYAN}Starting simulator...${NC}"
    xcrun simctl boot "$sim_id" 2>/dev/null || true
    
    # Wait for simulator to be ready
    sleep 3
    
    # Check if Simulator.app is running, if not launch it
    if ! pgrep -q "Simulator"; then
        echo -e "${CYAN}Launching Simulator.app...${NC}"
        open -a Simulator
        sleep 2
    fi
}

capture_screenshot() {
    local sim_id=$1
    local output_path=$2
    local description=$3
    
    if [ -n "$sim_id" ]; then
        xcrun simctl io "$sim_id" screenshot "$output_path" 2>/dev/null || true
        if [ -f "$output_path" ]; then
            echo -e "${GREEN}📸${NC} Screenshot: ${description}"
        fi
    fi
}

start_screenshot_monitor() {
    local sim_id=$1
    local output_dir=$2
    local interval=$3
    
    if [ "$interval" -le 0 ]; then
        return
    fi
    
    # Background process that captures screenshots periodically
    touch "${output_dir}/.monitoring"
    
    (
        counter=0
        while [ -f "${output_dir}/.monitoring" ]; do
            sleep "$interval"
            if [ -f "${output_dir}/.monitoring" ]; then
                capture_screenshot "$sim_id" "${output_dir}/auto_${counter}.png" "Auto-capture ${counter}"
                ((counter++))
            fi
        done
    ) &
    
    echo $! > "${output_dir}/.monitor_pid"
}

stop_screenshot_monitor() {
    local output_dir=$1
    
    if [ -f "${output_dir}/.monitor_pid" ]; then
        local pid=$(cat "${output_dir}/.monitor_pid")
        rm -f "${output_dir}/.monitoring"
        kill "$pid" 2>/dev/null || true
        rm -f "${output_dir}/.monitor_pid"
    fi
}

extract_screenshots_from_result_bundle() {
    local result_bundle=$1
    local output_dir=$2
    
    if [ ! -d "$result_bundle" ]; then
        echo -e "${YELLOW}⚠${NC} Result bundle not found: $result_bundle"
        return
    fi
    
    echo -e "${BLUE}Extracting XCTest screenshots from result bundle...${NC}"
    
    # Get all data file IDs from the result bundle
    local data_ids=$(ls "$result_bundle/Data/" 2>/dev/null | grep "^data\." | sed 's/^data\.//' || true)
    
    if [ -z "$data_ids" ]; then
        echo -e "${YELLOW}⚠${NC} No data files found in bundle"
        return
    fi
    
    local screenshot_count=0
    
    # Try to export each data file and check if it's a PNG
    for id in $data_ids; do
        local temp_file=$(mktemp)
        
        # Try to export this data file
        xcrun xcresulttool export --legacy --type file \
            --path "$result_bundle" \
            --id "$id" \
            --output-path "$temp_file" 2>/dev/null
        
        if [ -f "$temp_file" ]; then
            # Check if it's a PNG image
            local file_type=$(file -b "$temp_file" | head -1)
            if [[ "$file_type" == *"PNG image"* ]]; then
                local output_path="${output_dir}/xctest_${screenshot_count}.png"
                mv "$temp_file" "$output_path"
                echo -e "${GREEN}✓${NC} Extracted XCTest screenshot: xctest_${screenshot_count}.png"
                ((screenshot_count++))
            else
                rm -f "$temp_file"
            fi
        else
            rm -f "$temp_file"
        fi
    done
    
    if [ "$screenshot_count" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} Extracted ${screenshot_count} XCTest screenshot(s) from result bundle"
    else
        echo -e "${YELLOW}⚠${NC} No XCTest screenshots found in result bundle"
    fi
}

generate_summary_report() {
    local mode=$1
    local test_name=$2
    local test_result=$3
    local screenshot_dir=$4
    
    local summary_file="${SCREENSHOT_DIR}/summary.json"
    
    # Count screenshots
    local screenshot_count=$(find "$screenshot_dir" -name "*.png" 2>/dev/null | wc -l | xargs)
    
    # Create or append to summary JSON
    if [ ! -f "$summary_file" ]; then
        echo "{" > "$summary_file"
        echo "  \"timestamp\": \"$TIMESTAMP\"," >> "$summary_file"
        echo "  \"device\": \"$DEVICE\"," >> "$summary_file"
        echo "  \"ios_version\": \"$IOS_VERSION\"," >> "$summary_file"
        echo "  \"tests\": [" >> "$summary_file"
    else
        # Remove closing brackets to append
        sed -i '' '$ d' "$summary_file"
        sed -i '' '$ d' "$summary_file"
        echo "," >> "$summary_file"
    fi
    
    echo "    {" >> "$summary_file"
    echo "      \"mode\": \"$mode\"," >> "$summary_file"
    echo "      \"test_name\": \"${test_name:-all}\"," >> "$summary_file"
    echo "      \"result\": \"$test_result\"," >> "$summary_file"
    echo "      \"screenshot_count\": $screenshot_count," >> "$summary_file"
    echo "      \"screenshot_dir\": \"$(basename "$screenshot_dir")\"" >> "$summary_file"
    echo "    }" >> "$summary_file"
    echo "  ]" >> "$summary_file"
    echo "}" >> "$summary_file"
}

run_sdk_tests() {
    local test_name="${1:-}"
    
    print_header "🧪 Running AdaptiveCards SDK Tests"
    
    # Get simulator ID and set destination
    local sim_id=$(get_simulator_id)
    if [ -z "$sim_id" ]; then
        echo -e "${RED}❌ Could not find simulator: $DEVICE${NC}"
        return 1
    fi
    
    # Set destination using simulator ID
    DESTINATION="platform=iOS Simulator,id=${sim_id}"
    
    # Boot simulator if needed
    if ! xcrun simctl list devices | grep "$sim_id" | grep -q "Booted"; then
        boot_simulator "$sim_id"
    fi
    
    print_config
    
    echo -e "${YELLOW}ℹ${NC} SDK tests are unit tests without UI - skipping screenshot capture"
    echo ""
    
    local test_args=""
    if [ -n "$test_name" ]; then
        test_args="-only-testing:${SDK_TEST_TARGET}/${test_name}"
    fi
    
    # Create temp file for output
    local temp_log=$(mktemp)
    trap "rm -f $temp_log" EXIT
    
    echo -e "${BLUE}🔨 Building and testing SDK...${NC}"
    echo ""
    
    if [ -n "$test_args" ]; then
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "$SDK_SCHEME" \
            -destination "$DESTINATION" \
            $test_args \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Suite|Test Case|passed|failed|error:|warning:|Executed|^$|✅|❌)"
    else
        xcodebuild test \
            -workspace "$WORKSPACE" \
            -scheme "$SDK_SCHEME" \
            -destination "$DESTINATION" \
            2>&1 | tee "$temp_log" | grep -E "(Testing|Test Suite|Test Case|passed|failed|error:|warning:|Executed|^$|✅|❌)"
    fi
    
    local test_result=$?
    
    if [ $test_result -eq 0 ]; then
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ SDK TESTS PASSED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        grep -E "Test Suite.*passed|Executed.*tests" "$temp_log" | tail -3
        return 0
    else
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ SDK TESTS FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        grep -E "Test Case.*failed|error:" "$temp_log" | tail -20
        return 1
    fi
}

run_visualizer_tests() {
    local test_name="${1:-}"
    
    print_header "📱 Running ADCIOSVisualizer UI Tests with Screenshots"
    
    setup_screenshot_directory "visualizer"
    local screenshot_dir="${SCREENSHOT_DIR}/visualizer"
    
    print_config
    
    # Get simulator ID
    local sim_id=$(get_simulator_id)
    if [ -z "$sim_id" ]; then
        echo -e "${RED}❌ Could not find simulator: $DEVICE${NC}"
        return 1
    fi
    
    echo -e "${CYAN}Simulator ID: ${sim_id}${NC}"
    
    # Set destination using simulator ID
    DESTINATION="platform=iOS Simulator,id=${sim_id}"
    
    # Boot simulator if needed
    if ! xcrun simctl list devices | grep "$sim_id" | grep -q "Booted"; then
        boot_simulator "$sim_id"
    fi
    
    # Capture pre-test screenshot
    capture_screenshot "$sim_id" "${screenshot_dir}/00_pre_test.png" "Pre-test state"
    
    local test_args=""
    if [ -n "$test_name" ]; then
        test_args="-only-testing:${VISUALIZER_TEST_TARGET}/${test_name}"
        echo -e "${CYAN}Running specific UI test: ${test_name}${NC}"
    else
        # Run ONLY the UI tests, not unit tests
        test_args="-only-testing:${VISUALIZER_TEST_TARGET}"
        echo -e "${CYAN}Running all UI tests (ADCIOSVisualizerUITests)${NC}"
    fi
    echo ""
    
    # Create temp file for output
    local temp_log=$(mktemp)
    trap "rm -f $temp_log; stop_screenshot_monitor '$screenshot_dir'" EXIT
    
    echo -e "${BLUE}🔨 Building and testing Visualizer...${NC}"
    echo ""
    
    # Start xcodebuild in background and monitor for app launch
    (
        if [ -n "$test_args" ]; then
            SCREENSHOT_DIR="$screenshot_dir" xcodebuild test \
                -workspace "$WORKSPACE" \
                -scheme "$VISUALIZER_SCHEME" \
                -destination "$DESTINATION" \
                -resultBundlePath "$RESULT_BUNDLE_PATH" \
                $test_args \
                2>&1 | tee "$temp_log" | grep -E "(Testing|Test Case|KVO|OpenAI|Popover|PASS|FAIL|error:|warning:|✅|❌|Executed|^$)"
        else
            SCREENSHOT_DIR="$screenshot_dir" xcodebuild test \
                -workspace "$WORKSPACE" \
                -scheme "$VISUALIZER_SCHEME" \
                -destination "$DESTINATION" \
                -resultBundlePath "$RESULT_BUNDLE_PATH" \
                $test_args \
                2>&1 | tee "$temp_log" | grep -E "(Testing|Test Case|KVO|OpenAI|Popover|PASS|FAIL|error:|warning:|✅|❌|Executed|^$)"
        fi
    ) &
    
    local xcodebuild_pid=$!
    
    # Wait for app to actually launch (look for test case starting)
    echo -e "${MAGENTA}⏳ Waiting for test to start...${NC}"
    
    # Monitor the log file in the background and start screenshot capture when test starts
    (
        while true; do
            if grep -q "Test Case.*started" "$temp_log" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} Test started, launching screenshot monitor"
                # Start periodic screenshot monitoring if enabled
                if [ "$CAPTURE_INTERVAL" -gt 0 ]; then
                    echo -e "${MAGENTA}🔄 Starting screenshot monitor (interval: ${CAPTURE_INTERVAL}s)${NC}"
                    start_screenshot_monitor "$sim_id" "$screenshot_dir" "$CAPTURE_INTERVAL"
                fi
                break
            fi
            # Check if xcodebuild is still running
            if ! kill -0 $xcodebuild_pid 2>/dev/null; then
                break
            fi
            sleep 1
        done
    ) &
    
    local monitor_launch_pid=$!
    
    # Wait for xcodebuild to complete
    wait $xcodebuild_pid
    local xcodebuild_exit=$?
    
    # Stop screenshot monitor
    stop_screenshot_monitor "$screenshot_dir"
    
    # Capture post-test screenshot
    capture_screenshot "$sim_id" "${screenshot_dir}/99_post_test.png" "Post-test state"
    
    # Extract XCTest screenshots from result bundle
    echo ""
    extract_screenshots_from_result_bundle "$RESULT_BUNDLE_PATH" "$screenshot_dir" || true
    
    # Check actual test results from the log (more reliable than exit code)
    local test_result=0
    if grep -q "with 0 failures" "$temp_log" && grep -q "Test Suite.*passed" "$temp_log"; then
        test_result=0
    elif grep -q "Testing failed" "$temp_log" || grep -q "Test Case.*failed" "$temp_log"; then
        test_result=1
    else
        # Fallback to xcodebuild exit code
        test_result=$xcodebuild_exit
    fi
    
    # Generate summary report
    if [ $test_result -eq 0 ]; then
        generate_summary_report "visualizer" "$test_name" "passed" "$screenshot_dir"
        
        echo ""
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ VISUALIZER TESTS PASSED${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        echo ""
        echo -e "${BLUE}📊 Summary:${NC}"
        grep -E "Test Suite.*passed|Executed.*tests" "$temp_log" | tail -3
        
        echo ""
        echo -e "${MAGENTA}📸 Screenshots:${NC}"
        local screenshot_count=$(find "$screenshot_dir" -name "*.png" 2>/dev/null | wc -l | xargs)
        echo -e "  Location: ${CYAN}${screenshot_dir}${NC}"
        echo -e "  Count:    ${CYAN}${screenshot_count}${NC}"
        
        return 0
    else
        generate_summary_report "visualizer" "$test_name" "failed" "$screenshot_dir"
        
        # Capture failure screenshot
        capture_screenshot "$sim_id" "${screenshot_dir}/FAILURE.png" "Test failure state"
        
        echo ""
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ VISUALIZER TESTS FAILED${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        
        if grep -q "error:" "$temp_log"; then
            echo ""
            echo -e "${YELLOW}🔧 Compilation Errors:${NC}"
            grep "error:" "$temp_log" | tail -10
        fi
        
        echo ""
        echo -e "${RED}Test Failures:${NC}"
        grep -E "Test Case.*failed|assertion failed" "$temp_log" | tail -20
        
        echo ""
        echo -e "${MAGENTA}📸 Screenshots:${NC}"
        local screenshot_count=$(find "$screenshot_dir" -name "*.png" 2>/dev/null | wc -l | xargs)
        echo -e "  Location: ${CYAN}${screenshot_dir}${NC}"
        echo -e "  Count:    ${CYAN}${screenshot_count}${NC}"
        
        return 1
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# MAIN SCRIPT
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
    all)
        echo -e "${CYAN}Running all tests (SDK + Visualizer with screenshots)${NC}"
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
        echo -e "${MAGENTA}📸 Screenshots:${NC}"
        echo -e "  Location: ${CYAN}${SCREENSHOT_DIR}${NC}"
        
        if [ -f "${SCREENSHOT_DIR}/summary.json" ]; then
            echo -e "  Summary:  ${CYAN}${SCREENSHOT_DIR}/summary.json${NC}"
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
        print_header "Adaptive Cards Test Runner with Screenshots - Help"
        echo "Usage: $0 [mode] [test_name]"
        echo ""
        echo "Modes:"
        echo "  sdk        - Run AdaptiveCards framework unit tests (no screenshots)"
        echo "  visualizer - Run ADCIOSVisualizer UI tests with screenshot capture"
        echo "  all        - Run both SDK and Visualizer tests"
        echo ""
        echo "Examples:"
        echo "  $0 visualizer                       # Run all Visualizer tests with screenshots"
        echo "  $0 visualizer testPopoverRendering  # Run specific test with screenshots"
        echo "  $0 all                              # Run all tests"
        echo ""
        echo "Screenshot Features:"
        echo "  - Captures pre/post test state"
        echo "  - Periodic auto-capture during tests (configurable)"
        echo "  - Failure screenshots on test errors"
        echo "  - Extracts screenshots from XCTest result bundle"
        echo "  - Generates JSON summary report"
        echo ""
        echo "Configuration:"
        echo "  Device:           $DEVICE"
        echo "  iOS Version:      $IOS_VERSION"
        echo "  Screenshot Dir:   $SCREENSHOT_BASE_DIR"
        echo "  Capture Interval: ${CAPTURE_INTERVAL}s (0 = disabled)"
        echo ""
        echo "CI/CD Integration:"
        echo "  Screenshots are saved to: screenshots/<timestamp>/"
        echo "  Upload this directory as a build artifact"
        echo ""
        exit 0
        ;;
    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac
