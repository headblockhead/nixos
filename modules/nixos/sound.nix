{ pkgs, ... }: {
  security.rtkit.enable = true;
  services.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [
    pavucontrol
    paprefs
    qjackctl
    jack2
  ];

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
  };
}
