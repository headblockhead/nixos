# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
{ pkgs, system, inputs }: {
  home-manager = inputs.home-manager.packages.${system}.default;
  deploy-rs = inputs.deploy-rs.packages.${system}.default;

  # can be removed and moved to overlays when #396637 is merged
  librespot = pkgs.callPackage ../custom-packages/librespot.nix {
    withDNS-SD = true;
  };

  picotool = pkgs.callPackage ../custom-packages/picotool.nix {
    pico-sdk = pkgs.callPackage ../custom-packages/pico-sdk.nix { };
  };
  pico-sdk = pkgs.callPackage ../custom-packages/pico-sdk.nix { };

  openrgb = pkgs.libsForQt5.callPackage ../custom-packages/openrgb.nix {
    wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
    qtbase = pkgs.qt5.qtbase;
    qttools = pkgs.qt5.qttools;
    qmake = pkgs.qt5.qmake;
  };
  openrgb-plugin-effects = pkgs.callPackage ../custom-packages/openrgb-plugin-effects.nix {
    wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
    qtbase = pkgs.qt5.qtbase;
    qmake = pkgs.qt5.qmake;
  };
  openrgb-plugin-hardwaresync = pkgs.callPackage ../custom-packages/openrgb-plugin-hardwaresync.nix {
    wrapQtAppsHook = pkgs.qt5.wrapQtAppsHook;
    qtbase = pkgs.qt5.qtbase;
    qmake = pkgs.qt5.qmake;
  };
}
