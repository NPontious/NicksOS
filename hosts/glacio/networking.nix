{ config, pkgs, ... }:

{
  networking = {
    interfaces.eno0 = {
      useDHCP = true;
      #allowedTCPPorts = [ ];
      #allowedUDPPorts = [ ];
    };

    interfaces.enp4s0 = {
      ipv4.addresses = [{
        address = "192.168.100.1";
        prefixLength = 24;
      }];
    };

    nat.enable = false;

    firewall = {
      enable = true;
      trustedInterfaces = [ "enp4s0" "tailscale0" "docker0" "br+" ];
      extraCommands = "iptables -A INPUT -i enp4s0 -p vrrp -j ACCEPT";
      interfaces.eno1.allowedTCPPorts = [ ];
      checkReversePath = false;
    };
  };

  services.dnsmasq = {
    enable = true;

    settings = {
      interface = "enp4s0";
      dhcp-range = "192.168.100.50,192.168.100.150,12h";
      dhcp-option = "option:router";
    };
  };
}
