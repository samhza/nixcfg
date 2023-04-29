{config, ...}: {
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
      startWhenNeeded = true;
      extraConfig = ''
        AllowTcpForwarding yes
        X11Forwarding no
        AllowAgentForwarding no
        AllowStreamLocalForwarding no
        AuthenticationMethods publickey
        StreamLocalBindUnlink yes
        AllowUsers sam
      '';
    };
  };

  security.pam.enableSSHAgentAuth = true;

  services.dnscrypt-proxy2 = {
    #enable = true;
    settings = {
      ipv6_servers = true;
      require_dnssec = true;

      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/lib/dnscrypt-proxy2/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
      #server_names = [ "adguard-dns-doh" ];
    };
  };

  #systemd.services.dnscrypt-proxy2.serviceConfig = {
  #  StateDirectory = "dnscrypt-proxy";
  #};

  networking = {
    firewall = {
      enable = true;
      allowPing = false;
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [];
      allowedUDPPorts = [41641];
      checkReversePath = "loose";
    };
    networkmanager.enable = true;
    #nameservers = ["100.100.100.100" "127.0.0.1" "::1"];
    #networkmanager.dns = "none";
    useDHCP = false;
  };
  #services.resolved.fallbackDns = config.networking.nameservers;
}
