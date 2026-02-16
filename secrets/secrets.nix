let
  edwardh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
  rpi5-01 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtvhxOROlavY2jNZUgpD1BkTgDNavy/TuoLnDyGWxlV";
  rpi5-02 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRrQrfqhA5er+AW9/wcd6Wjex79Jn+IB6YNdXfzYbTY";
  rpi5-03 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/4Qh6r7a065byYqI9gEba44DRXDuUF6vbIUduk/EJF";
in
{
  # EDITOR="cp /dev/stdin" k3s token generate | agenix -e k3s-token.age
  # then nixos-rebuild boot, reboot, wait for failure
  # sudo cat /var/lib/rancher/k3s/server/token
  # update with that
  "k3s-token.age".publicKeys = [ rpi5-01 rpi5-02 rpi5-03 ];
  "mail-hashed-password.age".publicKeys = [ edwardh ];
  "radicale-htpasswd.age".publicKeys = [ edwardh ];
}
