let
  sam = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuLxp26yYiaPIz07V4X7a9N+PinBUGsnnVutZSpFaL";
  users = [ sam ];

  lilith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxZegC15ua0LbQ5Ut6mM++OUL6aq9WHx+JnqqJRDcwI";
  leliel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEjpjsgOvt8M2acZGHMCjRyro4myveL4o1Io+BjYuxu root@leliel";
  ramiel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILLpMNKO9nl04Sf/3M4JpLp/YiBdsdipqRD8WzKv1636 root@ramiel";
  bardiel = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILTo0x2lsZRYgArvlsOTuZixAzceZJsAHdQbFHIaZdLf root@bardiel";
  systems = [ lilith leliel ramiel bardiel ];
in
{
  "esammy.toml.age".publicKeys = [sam lilith ramiel];
  "cloudflare-samhza-com-creds.age".publicKeys = [sam ramiel bardiel];
  "ramiel-restic.age".publicKeys = [sam ramiel];
  "iwantmyname-creds.age".publicKeys = [sam ramiel];
  "spotify-password.age".publicKeys = [sam leliel];
  "postfix-sender_relay.age".publicKeys = [sam leliel];
  "migadu-sasl_passwd.age".publicKeys = [sam leliel];
  "gmail-sasl_passwd.age".publicKeys = [sam leliel];
  "healthcheck-id.age".publicKeys = [sam ramiel];
  "ntfy-netrc.age".publicKeys = [sam ramiel];
}
