{ inputs, ... }: {
  # Add custom packages to nixpkgs from our definitions in the 'pkgs' folder.
  additions = final: _prev: import ../pkgs { pkgs = final; inherit inputs; system = final.system; };

  # Modify existing packages in nixpkgs.
  modifications = final: prev: {
    google-chrome = prev.google-chrome.overrideAttrs (oldAttrs: {
      commandLineArgs = [
        "--ozone-platform=wayland"
        "--disable-features=WaylandFractionalScaleV1"
      ];
    });
    gnome-keyring = prev.gnome-keyring.overrideAttrs (oldAttrs: {
      mesonFlags = (builtins.filter (flag: flag != "-Dssh-agent=true") oldAttrs.mesonFlags) ++ [
        "-Dssh-agent=false"
      ];
    });
  };

  # nixpkgs-unstable and nixpkgs-master defined in flake inputs.
  unstable-packages = final: _prev: {
    # pkgs.unstable is the nixpkgs unstable branch.
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
    # pkgs.master is the nixpkgs master branch, very unstable, and no cache!
    master = import inputs.nixpkgs-master {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
