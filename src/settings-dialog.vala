/*
 * Copyright (C) 2026  J~Net Clocks
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

namespace Clocks {

[GtkTemplate (ui = "/org/gnome/clocks/ui/settings-dialog.ui")]
public class SettingsDialog : Adw.Window {
    private GLib.Settings settings;

    [GtkChild]
    private unowned Adw.ComboRow device_row;
    [GtkChild]
    private unowned Adw.SpinRow volume_row;
    [GtkChild]
    private unowned Adw.ActionRow sound_row;

    public SettingsDialog (Gtk.Window parent) {
        Object (transient_for: parent,
                title: _("Settings"));

        settings = new GLib.Settings ("org.gnome.clocks");

        var device_model = new Gtk.StringList ({
            _("Automatic"),
            _("HDMI"),
            _("Bluetooth")
        });
        device_row.set_model (device_model);

        var preference = settings.get_string ("alarm-output-device");
        if (preference == "hdmi") {
            device_row.selected = 1;
        } else if (preference == "bluetooth") {
            device_row.selected = 2;
        } else {
            device_row.selected = 0;
        }

        device_row.notify["selected"].connect (() => {
            string value = "auto";
            switch (device_row.selected) {
            case 1:
                value = "hdmi";
                break;
            case 2:
                value = "bluetooth";
                break;
            }
            settings.set_string ("alarm-output-device", value);
            settings.apply ();
        });

        volume_row.value = settings.get_double ("alarm-output-volume") * 100.0;
        volume_row.notify["value"].connect (() => {
            settings.set_double ("alarm-output-volume", volume_row.value / 100.0);
            settings.apply ();
        });

        update_sound_row ();
    }

    [GtkCallback]
    private void choose () {
        var dialog = new Gtk.FileDialog ();
        dialog.title = _("Choose Alarm Sound");

        var audio_filter = new Gtk.FileFilter ();
        audio_filter.name = _("Audio files");
        audio_filter.add_pattern ("*.wav");
        audio_filter.add_pattern ("*.mp3");
        audio_filter.add_pattern ("*.oga");
        audio_filter.add_pattern ("*.ogg");
        audio_filter.add_pattern ("*.flac");
        audio_filter.add_pattern ("*.opus");
        audio_filter.add_pattern ("*.m4a");
        audio_filter.add_pattern ("*.aac");
        audio_filter.add_pattern ("*.wma");
        audio_filter.add_pattern ("*.aiff");
        audio_filter.add_pattern ("*.webm");
        audio_filter.add_pattern ("*.mid");
        audio_filter.add_pattern ("*.midi");

        var all_filter = new Gtk.FileFilter ();
        all_filter.name = _("All files");
        all_filter.add_pattern ("*");

        var filters = new GLib.ListStore (typeof (Gtk.FileFilter));
        filters.append (audio_filter);
        filters.append (all_filter);
        dialog.filters = filters;

        dialog.open.begin (this, null, (obj, res) => {
            try {
                var file = dialog.open.end (res);
                if (file != null) {
                    settings.set_string ("alarm-sound-file", file.get_path ());
                    settings.apply ();
                    update_sound_row ();
                }
            } catch (Error e) {
                if (!(e is IOError.CANCELLED)) {
                    warning ("Failed to pick sound file: %s", e.message);
                }
            }
        });
    }

    [GtkCallback]
    private void reset_sound () {
        settings.set_string ("alarm-sound-file", "");
        settings.apply ();
        update_sound_row ();
    }

    [GtkCallback]
    private void test () {
        Utils.Bell.play_test ();
    }

    [GtkCallback]
    private void close_dialog () {
        close ();
    }

    private void update_sound_row () {
        var custom = settings.get_string ("alarm-sound-file");
        if (custom != null && ((string) custom).length > 0) {
            sound_row.subtitle = (string) custom;
        } else {
            sound_row.subtitle = _("Default: %s").printf (Utils.DEFAULT_ALARM_SOUND);
        }
    }
}

} // namespace Clocks