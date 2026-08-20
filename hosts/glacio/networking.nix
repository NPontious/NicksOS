{ config, pkgs, ... }:

{
  networking = {
    interfaces.eno0.useDHCP = true;

    interfaces.enp4s0 = {
      ipv4.addresses = [{
        address = "192.168.100.1";
        prefixLength = 24;
      }];
    };

    nat = {
      enable = true;
      externalInterface = "wlp5s0";
      internalInterfaces = [ "enp4s0" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "docker0" "br+" "enp4s0" ];
      extraCommands = ''
        iptables -A INPUT -i enp4s0 -p vrrp -j ACCEPT

        iptables -t mangle -A POSTROUTING -o wlp5s0 -j TTL --ttl-set 64
      '';
      extraStopCommands = ''
        iptables -t mangle -D POSTROUTING -o wlp5s0 -j TTL --ttl-set 64 || true
      '';
      checkReversePath = false;
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      interface = "enp4s0";
      dhcp-range = "192.168.100.50,192.168.100.150,12h";
      dhcp-option = [
        "option:router,192.168.100.1"
        "option:dns-server,192.168.100.1"
      ];
      server = [ "8.8.8.8" "1.1.1.1" ];
    };
  };
}
