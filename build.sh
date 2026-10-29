#!/bin/zsh
# Usage: ./build.sh  - builds for simulator, prints only compiler errors
xcodebuild -project StyleLab.xcodeproj -scheme StyleLab -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)" | sort -u | cut -c1-300 | head -30
