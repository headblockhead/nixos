let
  # Machine keys
  edward-desktop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs2G2Yt7+A53v5tymBcbAlWnT9tLZYNSW+XGqZU6ITh";
  edward-laptop-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGOkGgaa7J85LK4Vfe3+NvxxQObZspyRd50OkUQz/Ox";
  edward-dell-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiyDjr1nhiNjMkH4BCptfyb3UQ5xiPgMJlTxEA01FBr";
  edwardh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
  rpi5-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtvhxOROlavY2jNZUgpD1BkTgDNavy/TuoLnDyGWxlV";
  rpi5-02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRrQrfqhA5er+AW9/wcd6Wjex79Jn+IB6YNdXfzYbTY";
  rpi5-03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/4Qh6r7a065byYqI9gEba44DRXDuUF6vbIUduk/EJF";
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

  # K3s cluster
  "k3s-token.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];

  # Railreader
  "railreader-sftp-hashed-password.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "railreader-sftp-host-key.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "railreader-darwin-kafka-username.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "railreader-darwin-kafka-password.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "railreader-darwin-s3-access-key.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "railreader-darwin-s3-secret-key.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
}
