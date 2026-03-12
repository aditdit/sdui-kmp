#!/bin/zsh

set -e  # Exit on any error

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_step() { echo "\n${BLUE}▶ $1${NC}"; }
log_ok()   { echo "${GREEN}✓ $1${NC}"; }
log_err()  { echo "${RED}✗ $1${NC}"; exit 1; }

SCRIPT_DIR="${0:a:h}"
cd "$SCRIPT_DIR"

# Step 1: Copy iOS SDUIRenderer to React Native
log_step "[1/6] Copying iOS SDUIRenderer to React Native..."
cp packages/ios-swiftui/Sources/SDUI/SDUIRenderer.swift packages/react-native-sdui/ios/SDUIRenderer.swift \
  && log_ok "SDUIRenderer.swift copied" \
  || log_err "Failed to copy SDUIRenderer.swift"

# Step 2: Build shared module (Maven Local + XCFramework + JS)
log_step "[2/6] Building shared module (Maven + XCFramework + JS)..."
./gradlew :shared:publishToMavenLocal :packages:android-compose:publishToMavenLocal :shared:assembleSharedReleaseXCFramework :shared:jsBrowserDevelopmentLibraryDistribution \
  && log_ok "Shared module built successfully" \
  || log_err "Shared module build failed"

# Step 3: Copy XCFramework to React Native iOS
log_step "[3/6] Copying XCFramework to React Native iOS..."
cp -R shared/build/XCFrameworks/release/Shared.xcframework packages/react-native-sdui/ios/Frameworks/ \
  && log_ok "XCFramework copied" \
  || log_err "Failed to copy XCFramework"

# Step 4: Build React Native SDUI library using yarn workspace
log_step "[4/6] Building react-native-sdui library (yarn)..."
yarn workspace react-native-sdui run prepare \
  && log_ok "react-native-sdui built successfully" \
  || log_err "react-native-sdui build failed"

# Step 5: Pack library as .tgz and install in rn-sample
log_step "[5/6] Packing react-native-sdui and installing in rn-sample..."

# Pack using npm at the package directory to get the .tgz file
(cd "$SCRIPT_DIR/packages/react-native-sdui" && npm pack --quiet)
PACK_FILE=$(ls packages/react-native-sdui/react-native-sdui-*.tgz 2>/dev/null | tail -1)
log_ok "Packed → $PACK_FILE"

# Install into rn-sample using yarn at the workspace level
yarn workspace RnSdui install \
  && log_ok "react-native-sdui installed in rn-sample" \
  || log_err "yarn install in rn-sample failed"

# Step 6: Build Web
log_step "[6/6] Building Web app..."
cd "$SCRIPT_DIR/apps/web-sample"
npm run build \
  && log_ok "Web app built successfully" \
  || log_err "Web app build failed"

cd "$SCRIPT_DIR"

echo "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "${GREEN}✅  All platforms deployed successfully!${NC}"
echo "${YELLOW}   📦 RN Library packed & installed in apps/rn-sample${NC}"
echo "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
