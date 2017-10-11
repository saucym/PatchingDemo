# @yvanyang 2017.3.30

#准备工作  可以用pp助手下载越狱ipa文件 然后放到项目下的Patch目录中

# 1. 创建一个临时目录，把ipa文件解压到临时目录下，取app文件
TEMP_PATH="${SRCROOT}/Temp"
#TARGET_IPA_PATH="${SRCROOT}/Patch/a.ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/app.ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/微信-6.5.18(越狱应用).ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/app-wechat-resigned.ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/王者荣耀：无处不团，2亿好友都在玩-1.18.101(越狱应用).ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/追书神器-2.25.1.ipa"
#TARGET_IPA_PATH="${SRCROOT}/Patch/追书神器-2.24.14.ipa"

rm -rf "$TEMP_PATH" || true
mkdir -p "$TEMP_PATH" || true

unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app; echo "$1")


# 2. 更换demo工程编译出来的app文件, 把扩展删掉
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
rm -rf "$TARGET_APP_PATH" || true
mkdir -p "$TARGET_APP_PATH" || true
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH/"

rm -rf "$TARGET_APP_PATH/PlugIns" || true
rm -rf "$TARGET_APP_PATH/Watch" || true

rm -rf "$TARGET_APP_PATH/*.lproj" || true

#可改图标
echo "icon replace"
rm  "$TARGET_APP_PATH/AppIcon60x60@2x.png" || true
rm  "$TARGET_APP_PATH/Icon@2x.png" || true
cp "${SRCROOT}/Patch/AppIcon60x60@2x.png" "$TARGET_APP_PATH/AppIcon60x60@2x.png"  || true
cp "${SRCROOT}/Patch/AppIcon60x60@2x.png" "$TARGET_APP_PATH/Icon@2x.png"  || true
echo "icon replace finish"

# 3. 如果有app包含Framework的话，要对Framework进行代码签名.
TARGET_APP_FRAMEWORKS_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ]; then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do
FILENAME=$(basename $FRAMEWORK)
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

# 4. 最后把替换后的Info.plist转换为二进制文件,并添加运行权限. 更新BundleId
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
chmod +x "$TARGET_APP_PATH/$APP_BINARY"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"

#删除打开方式
/usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" "$TARGET_APP_PATH/Info.plist"
#删除文档支持类型
/usr/libexec/PlistBuddy -c "Delete :CFBundleDocumentTypes" "$TARGET_APP_PATH/Info.plist"
#删除scheme能力
/usr/libexec/PlistBuddy -c "Delete :LSApplicationQueriesSchemes" "$TARGET_APP_PATH/Info.plist"

#改名 可改微信app名字
TARGET_DISPLAY_NAME="看书"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $TARGET_DISPLAY_NAME" "$TARGET_APP_PATH/zh_CN.lproj/InfoPlist.strings"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $TARGET_DISPLAY_NAME" "$TARGET_APP_PATH/Info.plist"


# ---------------------------------------------------
# 5. Inject the Executable We Wrote and Built (XX.framework)

OPTOOL="${SRCROOT}/Injector/optool"

mkdir "$TARGET_APP_PATH/Dylibs"
cp "$BUILT_PRODUCTS_DIR/Injector.framework/Injector" "$TARGET_APP_PATH/Dylibs/Injector"
for file in `ls -1 "$TARGET_APP_PATH/Dylibs"`; do
echo -n '     '
echo "Install Load: $file -> @executable_path/Dylibs/$file"
"$OPTOOL" install -c load -p "@executable_path/Dylibs/$file" -t "$TARGET_APP_PATH/$APP_BINARY"
done

# Code sign
for DYLIB in "$TARGET_APP_PATH/Dylibs/"*
do
FILENAME=$(basename $DYLIB)
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$DYLIB"
done
