{ config, lib, pkgs, ... }:

{
  options.mySystem.services.arr.enable = lib.mkEnableOption "Arr Stack (Sonarr, Radarr, Lidarr, Prowlarr, qBittorrent, Gluetun)";

  config = lib.mkIf config.mySystem.services.arr.enable {
    services.sonarr = {
      enable = true;
      group = config.mySystem.mediaGroup;
    };

    services.radarr = {
      enable = true;
      group = config.mySystem.mediaGroup;
    };

    services.lidarr = {
      enable = true;
      group = config.mySystem.mediaGroup;
    };

    services.prowlarr = {
      enable = true;
    };

    systemd.services.lidarr.serviceConfig = {
      NoNewPrivileges = true;
      
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      
      SystemCallFilter = [ "@system-service" "~@privileged" ];

      ProtectSystem = "strict"; 
      ProtectHome = true;
      
      ReadWritePaths = [
        "/var/lib/lidarr"
        "/mnt/storage/media"
      ];
    };

    
    systemd.services.prowlarr.serviceConfig = {
      NoNewPrivileges = true;
      
      PrivateTmp = true;
      PrivateDevices = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      
      SystemCallFilter = [ "@system-service" "~@privileged" ];

      ProtectSystem = "strict"; 
      ProtectHome = true;
      
      ReadWritePaths = [
        "/var/lib/prowlarr"
        "/mnt/storage/media"
      ];
    };

    virtualisation.oci-containers.containers.gluetun = {
      image = "qmcgaw/gluetun:latest";
      extraOptions = [
        "--cap-add=NET_ADMIN"
        "--device=/dev/net/tun:/dev/net/tun"
      ];
      environment = {
        VPN_SERVICE_PROVIDER = "custom";
        VPN_TYPE = "wireguard";
        WIREGUARD_ENDPOINT_IP = "31.7.62.52";
        WIREGUARD_ENDPOINT_PORT = "443";
        WIREGUARD_PUBLIC_KEY = "3+ehrqWHaqA4lC10BRkscYasaewB2eamMSRda+HSkxQ=";
        VPN_PORT_FORWARDING = "off";
      };
      environmentFiles = [
        config.age.secrets."windscribe-creds".path
      ];
      ports = [
        "100.85.234.127:8081:8081/tcp"
        "6881:6881/tcp"
        "6881:6881/udp"
        "55000:55000/tcp"
        "55000:55000/udp"
      ];
    };

    virtualisation.oci-containers.containers.qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      dependsOn = [ "gluetun" ];
      extraOptions = [
        "--network=container:gluetun"
      ];
      environment = {
        PUID = "987";
        PGID = "983";
        WEBUI_PORT = "8081";
        QBITTORRENT__Session__InterfaceName = "tun0";
      };
      volumes = [
        "/var/lib/qbittorrent:/config"
        "/var/lib/qbittorrent/Downloads:/downloads"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/gluetun 0750 root root -"
      "d /var/lib/qbittorrent 0750 qbittorrent ${config.mySystem.mediaGroup} -"
      "d /var/lib/qbittorrent/Downloads 0775 qbittorrent ${config.mySystem.mediaGroup} -"
      "d /mnt/storage/media 0775 root ${config.mySystem.mediaGroup} -"
    ];

    users.users.qbittorrent = {
      isSystemUser = true;
      group = config.mySystem.mediaGroup;
      description = "qBittorrent User";
    };

    environment.systemPackages = with pkgs; [ wireguard-tools ];
    boot.kernelModules = [ "wireguard" ];

    age.secrets."windscribe-creds" = {
      file = ../secrets/windscribe-creds.age;
      mode = "0400";
    };
  };
}
