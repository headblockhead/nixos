{
  nix.gc = {
    automatic = true;
    persistent = false; # don't start garbage collection on boot if the last collection interval was missed.
    dates = "weekly";
    options = "--delete-older-than 7d"; # delete generations older than 7 days.
    randomizedDelaySec = "2d"; # random delay to (most likely) prevent all machines from doing gc at the same time.
  };
}
