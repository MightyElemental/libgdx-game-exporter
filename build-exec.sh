#!/bin/bash

# MIT License
# Copyright (c) 2022 MightyElemental
# https://github.com/MightyElemental/libgdx-game-exporter
# Build game into executables for various platforms

windowsjdk="OpenJDK11U-jre_x64_windows_hotspot_11.0.14.1_1.zip"
linuxjdk="OpenJDK11U-jre_x64_linux_hotspot_11.0.14.1_1.tar.gz"
buildlocation="desktop/build/libs"
# Change to your game's main class
mainclass="com.mygdx.game.DesktopLauncher"
# Change to what you want your game file to be called (excluding version)
gamename="libgdx-game"

# Set tag if missing
# The tag can be the game version
if [ -z "$TAG" ]; then
    # set TAG to the latest tag in git
    TAG=`git tag -l --sort=refname \*.\*.\* | tail -1`
fi

# Apply the version tag at the end of the name
gamename="$gamename-$TAG"

function build_game() {
    echo "Building game file with default method..."
    rm -rf build # ensure build dir is not present
    ./gradlew clean desktop:dist
}

# Ensure game was built
if ! compgen -G "$buildlocation/*.jar" > /dev/null; then
    echo "Game file was not built!"
    build_game
fi

# Ensure only one jar file is present
if [ $(ls $(compgen -G "$buildlocation/*.jar") -1 | wc -l) -gt 1 ]; then
    echo "Multiple jar files exist in the $buildlocation directory!"
    echo "Rebuilding game..."
    build_game
fi

# Rename game file
mv $(compgen -G "$buildlocation/*.jar") "$buildlocation/$gamename.jar"

# Create and enter build directory
mkdir -p builds && cd builds

# Download JRE for Windows
# https://github.com/adoptium/temurin11-binaries
wget -q -N --show-progress https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.14.1%2B1/OpenJDK11U-jre_x64_windows_hotspot_11.0.14.1_1.zip{,.sha256.txt}
# Download JRE for Linux
wget -q -N --show-progress https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.14.1%2B1/OpenJDK11U-jre_x64_linux_hotspot_11.0.14.1_1.tar.gz{,.sha256.txt}

# Compare Windows Hash
echo "comparing sha256 hash..."
sha256sum -c $windowsjdk.sha256.txt
if [ $? -eq 1 ]; then
    echo "Hash did not match!"
    exit 1
fi

# Compare Linux Hash
echo "comparing sha256 hash..."
sha256sum -c $linuxjdk.sha256.txt
if [ $? -eq 1 ]; then
    echo "Hash did not match!"
    exit 1
fi

# Download packr
# https://github.com/libgdx/packr
wget -N -q --show-progress https://github.com/libgdx/packr/releases/download/4.0.0/packr-all-4.0.0.jar -O packr4.jar

# Create exports folder
rm -rf "export"
mkdir -p "export"


# -= BUILD WINDOWS FILE =-


# remove windows directory if present
rm -rf windows

# Pack program into windows executable
java -jar packr4.jar \
--platform windows64 \
--jdk $windowsjdk \
--executable $gamename \
--classpath "../$buildlocation/$gamename.jar" \
--mainclass $mainclass \
--output windows

# Zip packaged windows executable
cd windows
zip -FSr "../export/$gamename-windows.zip" .
cd ..

echo "Completed Windows build"
echo "Starting Linux build"


# -= BUILD LINUX FILE =-


# remove linux directory if present
rm -rf linux

# Pack program into linux executable
java -jar packr4.jar \
--platform linux64 \
--jdk $linuxjdk \
--executable $gamename \
--classpath "../$buildlocation/$gamename.jar" \
--mainclass $mainclass \
--output linux

# Archive packaged linux executable
cd linux
tar -czvf "../export/$gamename-linux.tar.gz" *
cd ..

echo "Completed Linux build"