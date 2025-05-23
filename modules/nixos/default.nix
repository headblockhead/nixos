{
  basicConfig = import ./basicConfig.nix;
  bluetooth = import ./bluetooth.nix;
  bootloader = import ./bootloader.nix;
  desktop = import ./desktop.nix;
  desktopApps = import ./desktopApps.nix;
  development = import ./development.nix;
  distributedBuilds = import ./distributedBuilds.nix;
  fileSystems = import ./fileSystems.nix;
  fonts = import ./fonts.nix;
  git = import ./git.nix;
  gpg = import ./gpg.nix;
  headless = import ./headless.nix;
  homeManager = import ./homeManager.nix;
  kmscon = import ./kmscon.nix;
  monitoring = import ./monitoring.nix;
  network = import ./network.nix;
  openrgb = import ./openrgb.nix;
  p2pool = import ./p2pool.nix;
  printer = import ./printer.nix;
  sdr = import ./sdr.nix;
  sheepit = import ./sheepit.nix;
  snapclient = import ./snapclient.nix;
  sound = import ./sound.nix;
  ssd = import ./ssd.nix;
  ssh = import ./ssh.nix;
  users = import ./users.nix;
  virtualisation = import ./virtualisation.nix;
  xmrig = import ./xmrig.nix;
  yubikey = import ./yubikey.nix;
  zsh = import ./zsh.nix;
}
