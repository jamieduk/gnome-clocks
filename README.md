# J~Net Gnome-Clocks 46.0

https://github.com/jamieduk/gnome-clocks/

A fork of [GNOME Clocks 46.0](https://gitlab.gnome.org/GNOME/gnome-clocks) with custom alarm sound settings. Clocks, alarms, timers and world clocks for GNOME.

This version adds a **Settings** dialog so the alarm sound can be chosen, its volume controlled, and the output device selected — with a built-in **Test** button.

## Features

Everything from GNOME Clocks 46.0, plus:

- **Settings menu** (hamburger menu → *Settings*)
  - **Sound Output Device** — `Automatic`, `HDMI` or `Bluetooth`
    - Automatic uses a connected Bluetooth device (e.g. an Echo Dot), otherwise the built-in HDMI output
  - **Sound Volume** — default **100%**
  - **Custom Alarm Sound** — pick any audio file:
    - `wav`, `mp3`, `oga`, `ogg`, `flac`, `opus`, `m4a`, `aac`, `wma`, `aiff`, `webm`, `mid`…
  - **Test Alarm Sound** button — plays the configured sound at the configured device/volume
- Default alarm sound: `/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga`
- On ring, the app automatically:
  - selects the output device (Bluetooth when connected, otherwise HDMI / default)
  - unmutes the output and sets it to the configured volume (default max)
- `install.sh` builds and overwrites **every** copy of the old `gnome-clocks` binary (including `/usr/bin`), so the menu always launches this version

## Requirements

Ubuntu / Debian:

```bash
sudo apt install build-essential meson ninja-build pkg-config gettext valac itstool yelp-tools \
     libgtk-4-dev libadwaita-1-dev libgweather-4-dev libgeocode-glib-dev libgeoclue-2-dev \
     libgirepository1.0-dev libglib2.0-dev libjson-glib-dev libportal-dev libportal-gtk4-dev \
     desktop-file-utils libgtk-4-media-gstreamer
```

Other distros: install the equivalent `meson`, `ninja`, `vala`, GTK 4, libadwaita 1, GWeather 4, geocode-glib, geoclue, libportal and GStreamer GTK4 media packages.

## Build & Install

```bash
bash ./install.sh
```

The script:

1. configures the build (fresh `meson setup` if needed)
2. compiles
3. installs to `/usr/local`
4. overwrites every existing `gnome-clocks` binary with the new build
5. points all D-Bus service files and desktop launchers at the new binary
6. installs the bundled custom alarm sound to `/usr/share/sounds/freedesktop/stereo/`
7. compiles the GSettings schemas and refreshes the desktop database

If the menu still shows the old app after installing, log out and back in once.

## Settings (GSettings `org.gnome.clocks`)

| Key                     | Type   | Default | Description                                      |
|-------------------------|--------|---------|--------------------------------------------------|
| `alarm-sound-file`      | string | `""`    | Custom audio file path (empty = default sound)   |
| `alarm-output-device`   | string | `auto`  | `auto` \| `hdmi` \| `bluetooth`                  |
| `alarm-output-volume`   | double | `1.0`   | Volume 0.0–1.0 (1.0 = 100%)                      |

## Building manually

```bash
meson setup build --prefix=/usr/local --buildtype=release
meson compile -C build
sudo meson install -C build
```

## License

GPL-2.0-or-later. See [LICENSE.md](LICENSE.md).

GNOME Clocks is (c) The GNOME Project and contributors.
