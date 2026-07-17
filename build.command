#!/bin/bash
# =============================================================================
#  NoSleep 一键构建脚本
#  双击此文件即可编译、打包为 DMG 安装包
# =============================================================================

set -e

# ---------- 定位脚本所在目录 ----------
cd "$(dirname "$0")"

APP_NAME="NoSleep"
VERSION="1.0.0"
BUILD_DIR=".build"
DMG_NAME="${APP_NAME}-${VERSION}"
CONTENTS="$BUILD_DIR/$APP_NAME.app/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# ---------- 清理旧构建 ----------
rm -rf "$BUILD_DIR"
mkdir -p "$MACOS" "$RESOURCES"

echo ""
echo "========================================"
echo "        NoSleep 构建脚本"
echo "========================================"
echo ""

# ---------- 前置检查 ----------
if ! command -v swiftc &>/dev/null; then
    echo "❌ 未检测到 Swift 编译器"
    echo ""
    echo "   请先安装 Xcode Command Line Tools："
    echo "   打开「终端」，执行："
    echo ""
    echo "   xcode-select --install"
    echo ""
    echo "   安装完成后重新双击本脚本即可。"
    echo ""
    read -p "按回车键退出..."
    exit 1
fi

# ---------- [1/5] 生成图标 ----------
echo "[1/5] 生成应用图标..."

ICONSET="NoSleep.iconset"
ICON_SRC="icon_1024.png"

if [ -f "$ICON_SRC" ]; then
    rm -rf "$ICONSET"
    mkdir -p "$ICONSET"

    sips -z 16 16     "$ICON_SRC" --out "$ICONSET/icon_16x16.png"       &>/dev/null
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET/icon_16x16@2x.png"    &>/dev/null
    sips -z 32 32     "$ICON_SRC" --out "$ICONSET/icon_32x32.png"       &>/dev/null
    sips -z 64 64     "$ICON_SRC" --out "$ICONSET/icon_32x32@2x.png"    &>/dev/null
    sips -z 128 128   "$ICON_SRC" --out "$ICONSET/icon_128x128.png"     &>/dev/null
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET/icon_128x128@2x.png"  &>/dev/null
    sips -z 256 256   "$ICON_SRC" --out "$ICONSET/icon_256x256.png"     &>/dev/null
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET/icon_256x256@2x.png"  &>/dev/null
    sips -z 512 512   "$ICON_SRC" --out "$ICONSET/icon_512x512.png"     &>/dev/null
    sips -z 1024 1024 "$ICON_SRC" --out "$ICONSET/icon_512x512@2x.png"  &>/dev/null

    iconutil -c icns "$ICONSET" -o "$RESOURCES/AppIcon.icns"
    rm -rf "$ICONSET"
    echo "      ✓ 图标生成成功"
else
    echo "      ⚠ 未找到 icon_1024.png，跳过图标生成"
fi

# ---------- [2/5] 编译 ----------
echo "[2/5] 正在编译..."

swiftc -o "$MACOS/$APP_NAME" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework IOKit \
    -framework Combine \
    Sources/NoSleep/*.swift

echo "      ✓ 编译成功"

# ---------- [3/5] 生成 Info.plist ----------
echo "[3/5] 生成 Info.plist..."

cat > "$CONTENTS/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>NoSleep</string>
    <key>CFBundleIdentifier</key>
    <string>com.nosleep.app</string>
    <key>CFBundleName</key>
    <string>NoSleep</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>12.0</string>
</dict>
</plist>
EOF

echo "      ✓ Info.plist 生成成功"

# ---------- [4/5] 签名 ----------
echo "[4/5] 正在签名..."

SIGN_METHOD=""

DEV_ID=$(security find-identity -v -p codesigning 2>/dev/null \
    | grep -m1 "Developer ID Application" \
    | awk -F'"' '{print $2}' || true)

if [ -z "$DEV_ID" ]; then
    DEV_ID=$(security find-identity -v -p codesigning 2>/dev/null \
        | grep -m1 "Apple Development" \
        | awk -F'"' '{print $2}' || true)
fi

if [ -z "$DEV_ID" ]; then
    DEV_ID=$(security find-identity -v -p codesigning 2>/dev/null \
        | grep -m1 "Apple Distribution" \
        | awk -F'"' '{print $2}' || true)
fi

if [ -n "$DEV_ID" ]; then
    echo "      ✓ 找到签名证书: $DEV_ID"
    codesign --force --deep --sign "$DEV_ID" "$BUILD_DIR/$APP_NAME.app"
    SIGN_METHOD="正式签名 ($DEV_ID)"
else
    echo "      ⚠ 使用 ad-hoc 签名"
    codesign --force --deep --sign - "$BUILD_DIR/$APP_NAME.app"
    SIGN_METHOD="ad-hoc 签名"
fi

echo "      签名验证: $(codesign --verify --verbose=0 "$BUILD_DIR/$APP_NAME.app" 2>&1 || true)"

# ---------- [5/5] 打包 DMG ----------
echo "[5/5] 正在打包 DMG 安装包..."

DMG_OUTPUT="${DMG_NAME}.dmg"
DMG_STAGING="$BUILD_DIR/dmg_staging"
rm -rf "$DMG_STAGING"
mkdir -p "$DMG_STAGING"

# 复制 app 到 staging
cp -R "$BUILD_DIR/$APP_NAME.app" "$DMG_STAGING/"

# 创建「应用程序」快捷方式
ln -s /Applications "$DMG_STAGING/Applications"

# 创建 DMG（带自定义窗口大小）
rm -f "$DMG_OUTPUT"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_STAGING" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

# 清理 staging
rm -rf "$DMG_STAGING"

echo "      ✓ DMG 打包成功"

# ---------- 完成 ----------
DMG_SIZE=$(du -h "$DMG_OUTPUT" | awk '{print $4}')
echo ""
echo "========================================"
echo "        ✓ 构建完成!"
echo "========================================"
echo ""
echo "  安装包: $(pwd)/${DMG_NAME}.dmg"
echo "  大小:   $(du -h "$DMG_OUTPUT" | awk '{print $1}')"
echo "  签名:   $SIGN_METHOD"
echo ""
echo "──────────────────────────────────────"
echo "  使用方法:"
echo "    1. 双击项目目录下的 ${DMG_NAME}.dmg"
echo "    2. 将 NoSleep 拖到「应用程序」文件夹"
echo "    3. 打开「应用程序」，双击 NoSleep"
echo ""
echo "  分享给他人:"
echo "    直接把 .dmg 文件发给别人，双击即可安装"
echo "──────────────────────────────────────"
echo ""

# 自动打开 DMG
echo "正在打开安装包..."
open "$DMG_OUTPUT"

echo ""
read -p "按回车键关闭此窗口..."
