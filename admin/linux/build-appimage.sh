#! /bin/bash

# SPDX-FileCopyrightText: 2017 Nextcloud GmbH and Nextcloud contributors
# SPDX-FileCopyrightText: 2024 WorldPosta
# SPDX-License-Identifier: GPL-2.0-or-later

set -xe

# Posta Sync Branding - WorldPosta
# Note: EXECUTABLE_NAME must match what CMake builds (nextcloud)
# APPNAME is used for the final output filename
export APPNAME=${APPNAME:-PostaSync}
export EXECUTABLE_NAME=${EXECUTABLE_NAME:-nextcloud}
export APPLICATION_ICON=${APPLICATION_ICON:-Nextcloud}
export BUILD_UPDATER=${BUILD_UPDATER:-OFF}
export BUILDNR=${BUILDNR:-0000}
export DESKTOP_CLIENT_ROOT=${DESKTOP_CLIENT_ROOT:-/home/user}
export QT_BASE_DIR=${QT_BASE_DIR:-/usr}
export OPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR:-/usr/lib/x86_64-linux-gnu}
export VERSION_SUFFIX=${VERSION_SUFFIX:stable}
export OEM_THEME_DIR=${OEM_THEME_DIR:-}

# Set defaults
export SUFFIX=${PR_ID:=${DRONE_PULL_REQUEST:=master}}
if [ $SUFFIX != "master" ]; then
    SUFFIX="PR-$SUFFIX"
fi
if [ "$BUILD_UPDATER" != "OFF" ]; then
    BUILD_UPDATER=ON
fi

# Ensure we use gcc-11 on RHEL-like systems
if [ -e "/opt/rh/gcc-toolset-11/enable" ]; then
    source /opt/rh/gcc-toolset-11/enable
fi

mkdir /app

# Build client
mkdir build-client
cd build-client

# Use custom OEM theme if specified, otherwise use POSTASYNC.cmake
OEM_CMAKE_ARGS=""
if [ -n "$OEM_THEME_DIR" ]; then
    OEM_CMAKE_ARGS="-DOEM_THEME_DIR=${OEM_THEME_DIR}"
fi

cmake \
    -G Ninja \
    -DCMAKE_PREFIX_PATH=${QT_BASE_DIR} \
    -DOPENSSL_ROOT_DIR=${OPENSSL_ROOT_DIR} \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_TESTING=OFF \
    -DBUILD_UPDATER=$BUILD_UPDATER \
    -DMIRALL_VERSION_BUILD=$BUILDNR \
    -DMIRALL_VERSION_SUFFIX="$VERSION_SUFFIX" \
    -DCMAKE_UNITY_BUILD=ON \
    ${OEM_CMAKE_ARGS} \
    ${DESKTOP_CLIENT_ROOT}
cmake --build . --target all
DESTDIR=/app cmake --install .

# Move stuff around
cd /app

[ -d usr/lib/x86_64-linux-gnu ] && mv usr/lib/x86_64-linux-gnu/* usr/lib/

mkdir -p AppDir/usr/plugins
mv usr/lib64/*sync_vfs_suffix.so AppDir/usr/plugins || mv usr/lib/*sync_vfs_suffix.so AppDir/usr/plugins
mv usr/lib64/*sync_vfs_xattr.so  AppDir/usr/plugins || mv usr/lib/*sync_vfs_xattr.so  AppDir/usr/plugins

rm -rf usr/lib/cmake
rm -rf usr/include
rm -rf usr/mkspecs
rm -rf usr/lib/x86_64-linux-gnu/

# Don't bundle the explorer extensions as we can't do anything with them in the AppImage
rm -rf usr/share/caja-python/
rm -rf usr/share/nautilus-python/
rm -rf usr/share/nemo-python/

# The client-specific data dir also contains the translations, we want to have those in the AppImage.
mkdir -p AppDir/usr/share
mv usr/share/${EXECUTABLE_NAME} AppDir/usr/share/${EXECUTABLE_NAME}

# Move sync exclude to right location
mv /app/etc/*/sync-exclude.lst usr/bin/
rm -rf etc

# Find desktop file
DESKTOP_FILE=$(ls /app/usr/share/applications/*.desktop)

# Find icon - try PostaSync first, fallback to Nextcloud
ICON_FILE=""
if [ -f "usr/share/icons/hicolor/512x512/apps/${APPLICATION_ICON}.png" ]; then
    ICON_FILE="usr/share/icons/hicolor/512x512/apps/${APPLICATION_ICON}.png"
elif [ -f "usr/share/icons/hicolor/512x512/apps/Nextcloud.png" ]; then
    ICON_FILE="usr/share/icons/hicolor/512x512/apps/Nextcloud.png"
else
    # Find any available icon
    ICON_FILE=$(find usr/share/icons -name "*.png" -size +10k | head -1)
fi

# Use linuxdeploy to deploy
export APPIMAGE_NAME=linuxdeploy-x86_64.AppImage
wget -O ${APPIMAGE_NAME} --ca-directory=/etc/ssl/certs -c "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
chmod a+x ${APPIMAGE_NAME}
./${APPIMAGE_NAME} --appimage-extract
rm ./${APPIMAGE_NAME}
cp -r ./squashfs-root ./linuxdeploy-squashfs-root

export LD_LIBRARY_PATH=/app/usr/lib64:/app/usr/lib:${QT_BASE_DIR}/lib:/usr/local/lib/x86_64-linux-gnu:/usr/local/lib:/usr/local/lib64
./linuxdeploy-squashfs-root/AppRun --desktop-file=${DESKTOP_FILE} --icon-file=${ICON_FILE} --executable=usr/bin/${EXECUTABLE_NAME} --appdir=AppDir

# Use linuxdeploy-plugin-qt to deploy qt dependencies
export APPIMAGE_NAME=linuxdeploy-plugin-qt-x86_64.AppImage
wget -O ${APPIMAGE_NAME} --ca-directory=/etc/ssl/certs -c "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage"
chmod a+x ${APPIMAGE_NAME}
./${APPIMAGE_NAME} --appimage-extract
rm ./${APPIMAGE_NAME}
cp -r ./squashfs-root ./linuxdeploy-plugin-qt-squashfs-root

export PATH=${QT_BASE_DIR}/bin:${PATH}
export QML_SOURCES_PATHS=${DESKTOP_CLIENT_ROOT}/src/gui
./linuxdeploy-plugin-qt-squashfs-root/AppRun --appdir=AppDir

./linuxdeploy-squashfs-root/AppRun --desktop-file=${DESKTOP_FILE} --library=/usr/lib64/libsoftokn3.so --icon-file=${ICON_FILE} --executable=usr/bin/${EXECUTABLE_NAME} --appdir=AppDir --output appimage

# Workaround issue #103 and #7231
export APPIMAGETOOL=appimagetool-x86_64.AppImage
wget -O ${APPIMAGETOOL} --ca-directory=/etc/ssl/certs -c https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
chmod a+x ${APPIMAGETOOL}
rm -rf ./squashfs-root
./${APPIMAGETOOL} --appimage-extract
rm ./${APPIMAGETOOL}
cp -r ./squashfs-root ./appimagetool-squashfs-root
rm -rf ./squashfs-root
APPIMAGE=$(ls *.AppImage)
./"${APPIMAGE}" --appimage-extract
rm ./"${APPIMAGE}"
rm ./squashfs-root/usr/lib/libglib-2.0.so.0
LD_LIBRARY_PATH="$PWD/appimagetool-squashfs-root/usr/lib":$LD_LIBRARY_PATH PATH="$PWD/appimagetool-squashfs-root/usr/bin":$PATH appimagetool -n ./squashfs-root "${APPIMAGE}"

#move AppImage
export COMMIT=${GITHUB_SHA:=${DRONE_COMMIT}}
if [ ! -z "$COMMIT" ]
then
    export APPIMAGE_NAME="${APPNAME}-${SUFFIX}-${COMMIT}-x86_64.AppImage"
else
    export APPIMAGE_NAME="${APPNAME}-${SUFFIX}-x86_64.AppImage"
fi
mv *.AppImage ${DESKTOP_CLIENT_ROOT}/$APPIMAGE_NAME

# tell GitHub Actions the name of our appimage
if [ ! -z "$GITHUB_OUTPUT" ]; then
  echo "AppImage name: ${APPIMAGE_NAME}"
  echo "APPIMAGE_NAME=${APPIMAGE_NAME}" >> "$GITHUB_OUTPUT"
fi
