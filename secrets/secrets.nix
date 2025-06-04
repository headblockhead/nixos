let
  # Machine keys
  edward-desktop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs2G2Yt7+A53v5tymBcbAlWnT9tLZYNSW+XGqZU6ITh";
  edward-laptop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGOkGgaa7J85LK4Vfe3+NvxxQObZspyRd50OkUQz/Ox";
  edward-dell-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiyDjr1nhiNjMkH4BCptfyb3UQ5xiPgMJlTxEA01FBr";
  edwardh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
  rpi5-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtvhxOROlavY2jNZUgpD1BkTgDNavy/TuoLnDyGWxlV";
  gateway = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl5CJU+QEKdSV/ybMegoKGT+NamF1FBYcMcSRACZLvJ";

  editing-keys = [ edward-desktop-01 ];
in
{
  # Passwords
  "mail-hashed-password.age".publicKeys = [ edwardh ];
  "grafana-admin-password.age".publicKeys = [ gateway ];
  "radicale-htpasswd.age".publicKeys = [ edwardh ];

  # Nix Cache signing private keys
  "harmonia-signing-key.age".publicKeys = [ rpi5-01 ];
  "ncps-signing-key.age".publicKeys = editing-keys ++ [ rpi5-01 ];

  # WG0 (remote access to home servers): 172.16.10.0/24
  # Server
  "wg0-edwardh-key.age".publicKeys = [ edwardh ];
  # Client
  "wg0-gateway-key.age".publicKeys = [ gateway ];
  "wg0-gateway-preshared-key.age".publicKeys = [ edwardh gateway ];

  # WG1 (remote access to home servers and LAN): 172.16.11.0/24
  # Server
  "wg1-edwardh-key.age".publicKeys = [ edwardh ];
  # Clients
  "wg1-gateway-key.age".publicKeys = [ gateway ];
  "wg1-gateway-preshared-key.age".publicKeys = [ edwardh gateway ];
  "wg1-edward-laptop-01-key.age".publicKeys = [ edward-laptop-01 ];
  "wg1-edward-laptop-01-preshared-key.age".publicKeys = [ edwardh edward-laptop-01 ];
  "wg1-edward-dell-01-key.age".publicKeys = [ edward-dell-01 ];
  "wg1-edward-dell-01-preshared-key.age".publicKeys = [ edwardh edward-dell-01 ];

  # WG2 (remote access to home WAN): 172.16.12.0/24
  # Server
  "wg2-edwardh-key.age".publicKeys = [ edwardh ];
  # Clients
  "wg2-gateway-key.age".publicKeys = [ gateway ];
  "wg2-gateway-preshared-key.age".publicKeys = [ edwardh gateway ];
  "wg2-edward-laptop-01-key.age".publicKeys = [ edward-laptop-01 ];
  "wg2-edward-laptop-01-preshared-key.age".publicKeys = [ edwardh edward-laptop-01 ];
  "wg2-edward-dell-01-key.age".publicKeys = [ edward-dell-01 ];
  "wg2-edward-dell-01-preshared-key.age".publicKeys = [ edwardh edward-dell-01 ];
  # Clients: Phones
  "wg2-edwards-iphone-preshared-key.age".publicKeys = [ edwardh ];
}
