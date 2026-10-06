{ config, pkgs, ... }:

{
  networking = {
    networkmanager.unmanaged = [ "interface-name:ap0" ];

    interfaces.eno0.useDHCP = true;

    interfaces.enp4s0 = {
      ipv4.addresses = [{
        address = "192.168.100.1";
        prefixLength = 24;
      }];
    };

    interfaces.ap0 = {
      ipv4.addresses = [{
        address = "192.168.101.1";
        prefixLength = 24;
      }];
    };

    nat = {
      enable = true;
      externalInterface = "wlp5s0";
      internalInterfaces = [ "enp4s0" "ap0" ];
    };

    firewall = {
      enable = true;
      trustedInterfaces = [ "docker0" "br+" "enp4s0" "ap0" ];
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

  systemd.services.create-ap0 = {
    description = "Create virtual AP interface ap0 for hostapd";
    before = [ "hostapd.service" "network-addresses-ap0.service" ];
    wantedBy = [ "sys-subsystem-net-devices-ap0.device" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iw}/bin/iw phy phy0 interface add ap0 type __ap addr 9e:04:b6:97:24:37";
      ExecStop = "${pkgs.iw}/bin/iw dev ap0 del";
    };
  };

  services.hostapd = {
    enable = true;
    radios.ap0 = {
      band = "2g";
      channel = 1;
      countryCode = "US";
      networks.ap0 = {
        ssid = "inkypi-net";
        authentication = {
          mode = "wpa2-sha1";
          wpaPassword = "Sn1J1mZPitus9hJrkp8N";
        };
        settings = {
          ignore_broadcast_ssid = pkgs.lib.mkForce 1;
        };
      };
    };
  };

  services.dnsmasq = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      interface = [ "enp4s0" "ap0" ];
      dhcp-range = [
        "192.168.100.50,192.168.100.150,12h"
        "192.168.101.50,192.168.101.150,12h"
      ];
      server = [ "8.8.8.8" "1.1.1.1" ];
    };
  };
}
