{ ... }:
{
  virtualisation.oci-containers.containers.sheepit = {
    image = "sheepitrenderfarm/client:text";
    autoStart = true;
    environment = {
      SHEEP_LOGIN = "headblockhead";
      SHEEP_PASSWORD = "7oCDTgwaNULSHXimSegEFrXtnhE89KVvaeJ9HeAh"; # This is a render key, so it is safe to expose.
      SHEEP_HOSTNAME = "nixos-container";
      SHEEP_CORES = "8";
      SHEEP_MEMORY = "32GB";
    };
  };
}
