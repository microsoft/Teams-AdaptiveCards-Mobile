#!/usr/bin/env python3
"""
AdaptiveCards Diagnostic Log Viewer

Finds and displays logs from the simulator in an easy-to-read format.
Can filter by category, search for keywords, and show recent sessions.

Usage:
    ./view_logs.py                    # Show latest log
    ./view_logs.py --all              # Show all logs
    ./view_logs.py --category OpenAIApp  # Filter by category
    ./view_logs.py --search "height"     # Search for keyword
    ./view_logs.py --tail 50          # Show last 50 lines
    ./view_logs.py --live             # Live tail (follow mode)
"""

import os
import sys
import glob
import re
import argparse
from datetime import datetime
from pathlib import Path
import subprocess

# ANSI color codes
COLORS = {
    '🤖': '\033[35m',  # Magenta for OpenAI
    '🎨': '\033[36m',  # Cyan for Rendering
    '🌐': '\033[34m',  # Blue for Network
    '📄': '\033[37m',  # White for Parsing
    '❌': '\033[31m',  # Red for Error
    '⚠️': '\033[33m',  # Yellow for Warning
    '✅': '\033[32m',  # Green for Success
    '🔄': '\033[95m',  # Light Magenta for Lifecycle
    '🔵': '\033[94m',  # Light Blue for General
}
RESET = '\033[0m'
BOLD = '\033[1m'

def find_simulator_id():
    """Find the booted iPhone 16 simulator ID"""
    try:
        result = subprocess.run(
            ['xcrun', 'simctl', 'list', 'devices', 'available'],
            capture_output=True,
            text=True,
            check=True
        )
        
        for line in result.stdout.split('\n'):
            if 'iPhone 16' in line and 'Booted' in line:
                match = re.search(r'([A-F0-9-]{36})', line)
                if match:
                    return match.group(1)
    except subprocess.CalledProcessError:
        pass
    
    return None

def find_log_directory(simulator_id):
    """Find the AdaptiveCardsLogs directory in the simulator"""
    if not simulator_id:
        return None
    
    # Path pattern for simulator app data
    base_path = Path.home() / 'Library/Developer/CoreSimulator/Devices' / simulator_id / 'data/Containers/Data/Application'
    
    if not base_path.exists():
        return None
    
    # Search for AdaptiveCardsLogs in all app containers
    for app_dir in base_path.iterdir():
        log_dir = app_dir / 'Library/Application Support/AdaptiveCardsLogs'
        if log_dir.exists():
            return log_dir
    
    return None

def find_log_files(log_dir):
    """Find all log files in the directory, sorted by date (newest first)"""
    if not log_dir or not log_dir.exists():
        return []
    
    log_files = list(log_dir.glob('adaptivecards_session_*.log'))
    return sorted(log_files, key=lambda x: x.stat().st_mtime, reverse=True)

def parse_log_line(line):
    """Parse a log line and extract components"""
    # Format: [timestamp] [category] [file:line] function - message
    pattern = r'\[([^\]]+)\] \[([^\]]+)\] \[([^\]]+)\] ([^\s]+) - (.+)'
    match = re.match(pattern, line)
    
    if match:
        return {
            'timestamp': match.group(1),
            'category': match.group(2),
            'location': match.group(3),
            'function': match.group(4),
            'message': match.group(5)
        }
    return None

def colorize_line(line, emoji='🔵'):
    """Add color to log line based on emoji"""
    color = COLORS.get(emoji, RESET)
    return f"{color}{line}{RESET}"

def format_log_entry(parsed, show_location=True, show_function=True):
    """Format a parsed log entry for display"""
    if not parsed:
        return ""
    
    # Extract time from ISO timestamp
    try:
        dt = datetime.fromisoformat(parsed['timestamp'].replace('Z', '+00:00'))
        time_str = dt.strftime('%H:%M:%S.%f')[:-3]  # HH:MM:SS.mmm
    except:
        time_str = parsed['timestamp']
    
    # Build output
    parts = [
        f"{BOLD}{time_str}{RESET}",
        f"[{parsed['category']}]"
    ]
    
    if show_location:
        parts.append(f"({parsed['location']})")
    
    if show_function:
        parts.append(f"{parsed['function']}")
    
    parts.append(f"- {parsed['message']}")
    
    return " ".join(parts)

def view_log(log_file, category=None, search=None, tail=None, show_location=True, show_function=True):
    """View a log file with optional filtering"""
    if not log_file.exists():
        print(f"❌ Log file not found: {log_file}")
        return
    
    print(f"\n{BOLD}📋 Log File:{RESET} {log_file.name}")
    print(f"{BOLD}📅 Created:{RESET} {datetime.fromtimestamp(log_file.stat().st_mtime).strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{BOLD}📦 Size:{RESET} {log_file.stat().st_size:,} bytes")
    print("─" * 80)
    
    with open(log_file, 'r') as f:
        lines = f.readlines()
    
    # Apply tail if specified
    if tail:
        lines = lines[-tail:]
    
    # Filter and display
    displayed = 0
    for line in lines:
        line = line.strip()
        if not line:
            continue
        
        # Extract emoji from line
        emoji = None
        for e in COLORS.keys():
            if e in line:
                emoji = e
                break
        
        parsed = parse_log_line(line)
        if parsed:
            # Apply category filter
            if category and parsed['category'].lower() != category.lower():
                continue
            
            # Apply search filter
            if search and search.lower() not in line.lower():
                continue
            
            formatted = format_log_entry(parsed, show_location, show_function)
            print(colorize_line(formatted, emoji))
            displayed += 1
        else:
            # Print raw line if can't parse
            if not category and (not search or search.lower() in line.lower()):
                print(colorize_line(line, emoji))
                displayed += 1
    
    print("─" * 80)
    print(f"{BOLD}Displayed {displayed} lines{RESET}")

def live_tail(log_file):
    """Live tail the log file"""
    print(f"\n{BOLD}📡 Live tailing:{RESET} {log_file.name}")
    print(f"{BOLD}Press Ctrl+C to stop{RESET}")
    print("─" * 80)
    
    try:
        process = subprocess.Popen(
            ['tail', '-f', str(log_file)],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        for line in process.stdout:
            line = line.strip()
            if not line:
                continue
            
            emoji = None
            for e in COLORS.keys():
                if e in line:
                    emoji = e
                    break
            
            parsed = parse_log_line(line)
            if parsed:
                formatted = format_log_entry(parsed)
                print(colorize_line(formatted, emoji))
            else:
                print(colorize_line(line, emoji))
    
    except KeyboardInterrupt:
        print(f"\n{BOLD}Stopped tailing{RESET}")
        process.terminate()

def main():
    parser = argparse.ArgumentParser(
        description='View AdaptiveCards diagnostic logs from simulator',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                           # Show latest log
  %(prog)s --all                     # List all available logs
  %(prog)s --category OpenAIApp      # Filter by category
  %(prog)s --search "height"         # Search for keyword
  %(prog)s --tail 50                 # Show last 50 lines
  %(prog)s --live                    # Live tail (follow mode)
  %(prog)s --file session_20251012.log  # View specific log file
        """
    )
    
    parser.add_argument('--all', action='store_true', help='List all available log files')
    parser.add_argument('--category', help='Filter by category (e.g., OpenAIApp, Rendering)')
    parser.add_argument('--search', help='Search for keyword in logs')
    parser.add_argument('--tail', type=int, help='Show last N lines')
    parser.add_argument('--live', action='store_true', help='Live tail the log file')
    parser.add_argument('--file', help='View specific log file by name')
    parser.add_argument('--no-location', action='store_true', help='Hide file location')
    parser.add_argument('--no-function', action='store_true', help='Hide function names')
    
    args = parser.parse_args()
    
    # Find simulator and log directory
    print(f"{BOLD}🔍 Finding simulator logs...{RESET}")
    simulator_id = find_simulator_id()
    
    if not simulator_id:
        print(f"❌ Could not find booted iPhone 16 simulator")
        print(f"   Run: xcrun simctl boot 'iPhone 16'")
        return 1
    
    print(f"✅ Found simulator: {simulator_id}")
    
    log_dir = find_log_directory(simulator_id)
    
    if not log_dir:
        print(f"❌ Could not find AdaptiveCardsLogs directory")
        print(f"   Make sure the app has run at least once")
        return 1
    
    print(f"✅ Log directory: {log_dir}")
    
    log_files = find_log_files(log_dir)
    
    if not log_files:
        print(f"❌ No log files found in {log_dir}")
        return 1
    
    # Handle --all flag
    if args.all:
        print(f"\n{BOLD}📚 Available log files:{RESET}\n")
        for i, log_file in enumerate(log_files, 1):
            mtime = datetime.fromtimestamp(log_file.stat().st_mtime)
            size = log_file.stat().st_size
            print(f"  {i}. {log_file.name}")
            print(f"     Created: {mtime.strftime('%Y-%m-%d %H:%M:%S')} | Size: {size:,} bytes")
        return 0
    
    # Select log file
    if args.file:
        log_file = log_dir / args.file
        if not log_file.exists():
            print(f"❌ Log file not found: {log_file}")
            return 1
    else:
        log_file = log_files[0]  # Most recent
    
    # View log
    if args.live:
        live_tail(log_file)
    else:
        view_log(
            log_file,
            category=args.category,
            search=args.search,
            tail=args.tail,
            show_location=not args.no_location,
            show_function=not args.no_function
        )
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
