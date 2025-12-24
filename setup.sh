#!/bin/bash

# Audio Production Pipeline - Setup Script
# This script installs all dependencies and verifies system requirements

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   🎵 Audio Production Pipeline - Setup Script              ║"
echo "║   Part 1, 2, 3, 4 Merge with TTS Generation               ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0

# Helper functions
check_command() {
    local cmd=$1
    local friendly_name=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✅${NC} $friendly_name found: $(command -v $cmd)"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${RED}❌${NC} $friendly_name NOT found"
        ((CHECKS_FAILED++))
        return 1
    fi
}

check_python_package() {
    local package=$1
    local import_name=${2:-$1}
    
    if python3 -c "import $import_name" 2>/dev/null; then
        echo -e "${GREEN}✅${NC} Python package '$package' installed"
        ((CHECKS_PASSED++))
        return 0
    else
        echo -e "${YELLOW}⚠️${NC}  Python package '$package' NOT installed"
        ((CHECKS_FAILED++))
        return 1
    fi
}

install_python_package() {
    local package=$1
    
    echo -e "${YELLOW}📦 Installing $package...${NC}"
    pip3 install "$package" --upgrade
}

echo "Step 1: Checking System Requirements"
echo "═════════════════════════════════════════════════════════════"

check_command "python3" "Python 3"
check_command "pip3" "pip3"
check_command "ffmpeg" "FFmpeg"

echo ""
echo "Step 2: Checking Python Packages"
echo "═════════════════════════════════════════════════════════════"

PYDUB_INSTALLED=$(check_python_package "pydub" "pydub" || true)
REQUESTS_INSTALLED=$(check_python_package "requests" "requests" || true)

echo ""
echo "Step 3: System Check Results"
echo "═════════════════════════════════════════════════════════════"

if ! command -v "python3" &> /dev/null; then
    echo -e "${RED}❌ CRITICAL: Python 3 is required${NC}"
    echo "   Install from: https://www.python.org/downloads/"
    exit 1
fi

if ! command -v "ffmpeg" &> /dev/null; then
    echo -e "${RED}❌ CRITICAL: FFmpeg is required${NC}"
    echo "   Install with:"
    echo "     macOS: brew install ffmpeg"
    echo "     Ubuntu/Debian: sudo apt-get install ffmpeg"
    echo "     CentOS: sudo yum install ffmpeg"
    exit 1
fi

echo ""
echo "Step 4: Installing/Upgrading Python Dependencies"
echo "═════════════════════════════════════════════════════════════"

if ! python3 -c "import pydub" 2>/dev/null; then
    install_python_package "pydub"
fi

if ! python3 -c "import requests" 2>/dev/null; then
    install_python_package "requests"
fi

echo ""
echo "Step 5: Verifying Installation"
echo "═════════════════════════════════════════════════════════════"

python3 -c "import pydub; print(f'✅ pydub version: {pydub.__version__}')"
python3 -c "import requests; print(f'✅ requests version: {requests.__version__}')"

FFMPEG_VERSION=$(ffmpeg -version | head -n1)
echo "✅ $FFMPEG_VERSION"

PYTHON_VERSION=$(python3 --version)
echo "✅ $PYTHON_VERSION"

echo ""
echo "Step 6: File Verification"
echo "═════════════════════════════════════════════════════════════"

if [ -f "final.json" ]; then
    echo -e "${GREEN}✅${NC} Configuration file found: final.json"
    echo "   Size: $(du -h final.json | cut -f1)"
else
    echo -e "${RED}❌${NC} Configuration file NOT found: final.json"
fi

if [ -f "audio_merger.py" ]; then
    echo -e "${GREEN}✅${NC} Audio merger script found: audio_merger.py"
    echo "   Size: $(du -h audio_merger.py | cut -f1)"
else
    echo -e "${RED}❌${NC} Audio merger script NOT found: audio_merger.py"
fi

echo ""
echo "Step 7: Creating Output Directory"
echo "═════════════════════════════════════════════════════════════"

mkdir -p audio_output
echo -e "${GREEN}✅${NC} Output directory ready: audio_output/"

echo ""
echo "Step 8: Checking TTS Service"
echo "═════════════════════════════════════════════════════════════"

# Check primary service
echo -n "Checking primary TTS service (port 8880)... "
if curl -s http://localhost:8880/health > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${YELLOW}⚠️  Not responding${NC}"
fi

# Check fallback service
echo -n "Checking fallback TTS service (port 5005)... "
if curl -s http://localhost:5005/docs > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${YELLOW}⚠️  Not responding${NC}"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   ✅ Setup Complete!                                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

echo "📋 Summary:"
echo "   ✅ Passed checks: $CHECKS_PASSED"
echo "   ❌ Failed checks: $CHECKS_FAILED"
echo ""

echo "🚀 Next Steps:"
echo "   1. Ensure TTS services are running (Docker containers)"
echo "   2. Review final.json configuration if needed"
echo "   3. Run the audio production pipeline:"
echo "      $ python3 audio_merger.py"
echo ""

echo "📚 Documentation:"
echo "   See AUDIO_PRODUCTION_README.md for detailed information"
echo ""

if [ $CHECKS_FAILED -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some requirements may be missing. See above for details.${NC}"
else
    echo -e "${GREEN}✅ All requirements satisfied! Ready to generate audio.${NC}"
fi

echo ""
