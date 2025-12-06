{ pkgs, lib, accounts, ... }:
{
  programs.dconf = {
    enable = true;
    profiles = {
      user.databases = [
        {
          settings = {
            "ca/desrt/dconf-editor" = {
              show-warning = false;
            };

            "org/gnome/desktop/background" = {
              picture-uri = "file://${pkgs.nixos-artwork.wallpapers.nineish.gnomeFilePath}";
              picture-uri-dark = "file://${pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath}";
            };
            "org/gnome/desktop/calendar" = {
              show-weekdate = true;
            };
            "org/gnome/desktop/datetime" = {
              automatic-timezone = true;
            };
            "org/gnome/desktop/input-sources" = {
              sources = [ "('xkb', 'us')" "('xkb', 'gb')" "('xkb', 'us+workman')" ];
              xkb-options = [ "terminate:ctrl_alt_bksp" "lv3:ralt_switch" "compose:rctrl" ];
            };
            "org/gnome/desktop/interface" = {
              clock-format = "24h";
              clock-show-date = true;
              clock-show-seconds = true;
              clock-show-weekday = true;
              color-scheme = "prefer-dark";
              gtk-theme = "Adwaita";
              show-battery-percentage = true;
              monospace-font-name = "SauceCodePro Nerd Font 12";
            };
            "org/gnome/desktop/lockdown" = {
              disable-show-password = true;
            };
            "org/gnome/desktop/notifications" = {
              show-in-lock-screen = false;
            };
            "org/gnome/desktop/peripherals/touchpad" = {
              disable-while-typing = false;
            };
            "org/gnome/desktop/privacy" = {
              old-files-age = lib.gvariant.mkInt32 7;
              recent-files-max-age = lib.gvariant.mkInt32 7;
              remove-old-temp-files = true;
              remove-old-trash-files = true;

              remember-app-usage = false;
              remember-recent-files = false;
            };
            "org/gnome/desktop/screen-time-limits" = {
              history-enabled = false;
            };
            "org/gnome/desktop/session" = {
              idle-delay = lib.gvariant.mkUint32 0; # Don't automatically blank the screen when idle.
            };

            "org/gnome/gnome-session" = {
              auto-save-session = true;
            };

            "org/gnome/nautilus/list-view" = {
              default-zoom-level = "small";
              use-tree-view = false;
              default-visible-columns = [ "name" "size" "date_modified" "deatiled_type" ];
            };
            "org/gnome/nautilus/preferences" = {
              default-folder-viewer = "list-view";
            };
            "org/gnome/nautilus/compression" = {
              default-compression-format = "7z";
            };
            "org/gnome/nautilus/icon-view" = {
              default-zoom-level = "small-plus";
            };

            "org/gnome/settings-daemon/plugins/color" = {
              night-light-enabled = true;
              night-light-schedule-automatic = true;
              night-light-temperature = lib.gvariant.mkUint32 3200;
            };
            "org/gnome/settings-daemon/plugins/housekeeping" = {
              free-percent-notify = lib.gvariant.mkDouble 0.05;
              free-percent-notify-again = lib.gvariant.mkDouble 0.01;
              free-size-gb-no-notify = lib.gvariant.mkInt32 30;
            };
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings = [ "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" ];
            };
            "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
              name = "Terminal";
              command = "ptyxis -s";
              binding = "<Control><Alt>t";
            };
            "org/gnome/settings-daemon/plugins/power" = {
              power-button-action = "interactive";
              sleep-inactive-ac-type = "nothing";
              sleep-inactive-battery-timeout = lib.gvariant.mkInt32 1800;
            };

            "org/gnome/shell" = {
              enabled-extensions = [
                "AlphabeticalAppGrid@stuarthayhurst" # Force app grid to be in alphabetical order
                "appindicatorsupport@rgcjonas.gmail.com" # "tray icons"
                "blur-my-shell@aunetx" # Add fancy blur effect to various UI elements
                "display-brightness-ddcutil@themightydeity.github.com" # Control physical monitor brightness for external monitors
                "desktop-cube@schneegans.github.com" # 3D cube for switching workspaces
                "unblank@sun.wxg@gmail.com" # Prevent screen from blanking immediatly when locked
              ];
            };
            "org/gnome/shell/weather" = {
              automatic-location = true;
            };
            "org/gnome/shell/extensions/display-brightness-ddcutil" = {
              ddcutil-binary-path = "${pkgs.ddcutil}/bin/ddcutil";
              button-location = lib.gvariant.mkInt32 1; # system menu
              position-system-menu = lib.gvariant.mkDouble 2.0;
              hide-system-indicator = true;
              show-all-slider = true;
              only-all-slider = true;
              show-display-name = false;
            };
            "org/gnome/shell/extensions/blur-my-shell/panel" = {
              override-background-dynamically = true; # Un-blur/darken the panel when a window is near.
            };
            "org/gnome/shell/extensions/unblank" = {
              power = true; # Delay screen blanking only when plugged-in.
              time = lib.gvariant.mkInt32 300; # Blank after 5 minutes.
            };

            "org/gnome/mutter" = {
              experimental-features = [ "scale-monitor-framebuffer" "kms-modifiers" "autoclose-xwayland" "variable-refresh-rate" "xwayland-native-scaling" ];
              dynamic-workspaces = false;
              workspaces-only-on-primary = false;
            };
            "org/gnome/desktop/wm/preferences" = {
              num-workspaces = lib.gvariant.mkInt32 4;
            };

            "org/gnome/system/location" = {
              enabled = false;
            };

            "org/gtk/gtk4/settings/file-chooser" = {
              show-hidden = true;
            };

            "org/gnome/Ptyxis" = {
              profile-uuids = [ "af255d8b5e5ef23e7d40d82b68ea9158" ];
              default-profile-uuid = "af255d8b5e5ef23e7d40d82b68ea9158";
            };
            "org/gnome/Ptyxis/Profiles/af255d8b5e5ef23e7d40d82b68ea9158" = {
              label = "NixOS";
              palette = "xterm";
              login-shell = true;
              limit-scrollback = false;
            };
          };
        }
      ];
    };
  };

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome = {
    enable = true;
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    nssmdns6 = true;
    publish = {
      userServices = true;
      hinfo = true;
      workstation = true;
    };
  };

  # Set default desktopManager type to gnome-wayland, and add user icon.
  systemd.tmpfiles.rules =
    lib.forEach accounts (account: "f+ /var/lib/AccountsService/users/${account.username} 0600 root root - [User]\\nSession=gnome\\nIcon=/var/lib/AccountsService/icons/${account.username}\\nSystemAccount=false\\n")
    ++
    lib.forEach accounts (account: "L+ /var/lib/AccountsService/icons/${account.username} - - - - ${account.profileicon}");

  boot = {
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "plymouth.use-simpledrm=1"
    ];
    initrd.verbose = false;
    loader.timeout = 0;
    plymouth.enable = true;
  };

  # Touchpad/touchscreen support.
  services.libinput.enable = true;

  # Bluetooth support.
  hardware.bluetooth.enable = true;

  # Exclude certain xserver packages.
  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.systemPackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.unblank
    gnomeExtensions.desktop-cube
    gnomeExtensions.alphabetical-app-grid
    gnomeExtensions.blur-my-shell
    gnomeExtensions.brightness-control-using-ddcutil
    ddcutil

    dconf-editor
    ptyxis

    adwaita-icon-theme
    adwaita-qt

    nerd-fonts.sauce-code-pro
  ];
  boot.kernelModules = [ "i2c-dev" ]; # For ddcutil

  services.gnome = {
    gnome-online-accounts.enable = true;
    gnome-keyring.enable = true;
    gnome-settings-daemon.enable = true;
  };

  # Exclude certain default gnome apps.
  # See https://github.com/NixOS/nixpkgs/blob/nixos-25.05/nixos/modules/services/x11/desktop-managers/gnome.nix#L414 for ideas.
  environment.gnome.excludePackages = (with pkgs; [
    epiphany
    gnome-calendar
    gnome-contacts
    gnome-music
    gnome-tour
    gnome-weather
    gnome-console
    snapshot
    totem
  ]);

  # Add udev rules.
  services.udev.packages = with pkgs; [
    gnome-settings-daemon
  ];

  qt = {
    enable = true;
    style = "adwaita-dark";
    platformTheme = "gnome";
  };

  # Symlink fonts into /run/current-system/sw/share/X11/fonts
  fonts.fontDir.enable = true;

  # High-performance version of D-Bus
  services.dbus.implementation = "broker";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    GSK_RENDERER = "ngl";
  };

  # Do not wait for network on boot.
  systemd.network.wait-online.timeout = 0;
}
