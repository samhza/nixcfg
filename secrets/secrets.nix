let
  sam = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuLxp26yYiaPIz07V4X7a9N+PinBUGsnnVutZSpFaL";
  users = [ sam ];

  lilith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxZegC15ua0LbQ5Ut6mM++OUL6aq9WHx+JnqqJRDcwI";
  ramiel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLpMNKO9nl04Sf/3M4JpLp/YiBdsdipqRD8WzKv1636 root@ramiel";
  systems = [ lilith ];
in
{
  "esammy.toml.age".publicKeys = [sam lilith ramiel];
  "cloudflare-samhza-com-creds.age".publicKeys = [sam ramiel];
  "spotify-password.age".publicKeys = [sam lilith];
}
