#!/bin/bash
# (c) J~Net 2025
#
# Build, install and overwrite ALL copies of gnome-clocks
# with this (J~Net) version.
#
# Works from anywhere (e.g. after cloning from GitHub).
#
# ./install.sh
set -euo pipefail

sudo apt install -y build-essential meson ninja-build pkg-config gettext valac itstool yelp-tools \
     libgtk-4-dev libadwaita-1-dev libgweather-4-dev libgeocode-glib-dev libgeoclue-2-dev \
     libgirepository1.0-dev libglib2.0-dev libjson-glib-dev libportal-dev libportal-gtk4-dev \
     desktop-file-utils libgtk-4-media-gstreamer
     
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

BUILD="$SCRIPT_DIR/build-jnet"
NEW_BIN="$BUILD/src/gnome-clocks"
INSTALL_BIN="/usr/local/bin/gnome-clocks"
SYSTEM_BIN="/usr/bin/gnome-clocks"

echo "=== 1. Configuring the build (fresh checkout support) ==="
if [ ! -d "$BUILD" ]; then
    meson setup "$BUILD" "$SCRIPT_DIR" \
        --prefix=/usr/local \
        --buildtype=release
else
    echo "  build dir already exists"
fi

echo
echo "=== 2. Building J~Net Clocks ==="
meson compile -C "$BUILD"

echo
echo "=== 3. Installing to /usr/local (binary, schema, desktop, dbus, icons) ==="
sudo meson install -C "$BUILD"

echo
echo "=== 4. Overwriting EVERY copy of the binary with the new build ==="
sudo cp -f "$NEW_BIN" "$INSTALL_BIN"
sudo cp -f "$NEW_BIN" "$SYSTEM_BIN"
sudo chmod 755 "$INSTALL_BIN" "$SYSTEM_BIN"

echo
echo "=== 5. Pointing ALL D-Bus service files at the new binary ==="
for f in \
    /usr/local/share/dbus-1/services/org.gnome.clocks.service \
    /usr/share/dbus-1/services/org.gnome.clocks.service
do
    sudo tee "$f" > /dev/null <<'EOF'
[D-BUS Service]
Name=org.gnome.clocks
Exec=/usr/local/bin/gnome-clocks --gapplication-service
EOF
    echo "  updated $f"
done

echo
echo "=== 6. Pointing ALL desktop launchers at the new binary ==="
for f in \
    /usr/local/share/applications/org.gnome.clocks.desktop \
    /usr/share/applications/org.gnome.clocks.desktop
do
    sudo tee "$f" > /dev/null <<'EOF'
[Desktop Entry]
Name=Clocks
Comment=Clocks, alarms, timers and world clocks
Exec=/usr/local/bin/gnome-clocks %U
Icon=org.gnome.clocks
Terminal=false
Type=Application
StartupNotify=true
Categories=GNOME;GTK;Utility;Clock;
Keywords=Clock;Alarm;Timer;Stopwatch;World;
DBusActivatable=false
EOF
    echo "  updated $f"
done

echo
echo "=== 7. Installing the custom alarm sound to the system path ==="
if [ -f "$SCRIPT_DIR/alarm-clock-elapsed.oga" ]; then
    sudo cp -f "$SCRIPT_DIR/alarm-clock-elapsed.oga" \
        /usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga
    echo "  sound installed"
fi

echo
echo "=== 8. Compiling GSettings schemas ==="
sudo glib-compile-schemas /usr/local/share/glib-2.0/schemas
sudo glib-compile-schemas /usr/share/glib-2.0/schemas
echo "  schemas compiled"

echo
echo "=== 9. Stopping any running Clocks ==="
sudo pkill -x gnome-clocks 2>/dev/null || true
sleep 1

echo
echo "=== 10. Refreshing desktop database and caches ==="
sudo update-desktop-database /usr/local/share/applications 2>/dev/null || true
sudo update-desktop-database /usr/share/applications 2>/dev/null || true
rm -f "$HOME/.cache/gnome-shell/app-system-cache.json" 2>/dev/null || true

echo
echo "=== Done ==="
echo "Build:        $(md5sum "$NEW_BIN" | cut -d' ' -f1)"
echo "Installed:    $(md5sum "$INSTALL_BIN" | cut -d' ' -f1)"
echo "System copy:  $(md5sum "$SYSTEM_BIN" | cut -d' ' -f1)"
echo
echo "Clocks is now the new build everywhere. Launch it from the menu."
echo "If the menu still shows the old app, log out and back in once."
