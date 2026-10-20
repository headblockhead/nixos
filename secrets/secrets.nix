let
  edwardh-alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
  gateway-alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOh5SMZFuDFcQiA4d9eR1L7NRCzh7CC1LKewLORvTcYe";
  rpi5-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtvhxOROlavY2jNZUgpD1BkTgDNavy/TuoLnDyGWxlV";
in
{
  "mail-hashed-password.age".publicKeys = [ edwardh-alpha ];
  "radicale-htpasswd.age".publicKeys = [ edwardh-alpha ];

  "tranquil-pds.age".publicKeys = [ rpi5-01 ];
  "knot-rs.age".publicKeys = [ rpi5-01 ];

  "gateway-alpha-wg.age".publicKeys = [ gateway-alpha ];
  "edwardh-alpha-wg.age".publicKeys = [ edwardh-alpha ];
}
