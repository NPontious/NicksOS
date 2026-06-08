{ config, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    group = "media";
  };

  services.radarr = {
    enable = true;
    group = "media";
  };

  services.lidarr = {
    enable = true;
    group = "media";
  };

  services.prowlarr = {
    enable = true;
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
      VPN_PORT_FORWARDING = "on";
      VPN_PORT_FORWARDING_PROVIDER = "windscribe";
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
      # Ensure qBittorrent uses the VPN interface
      QBITTORRENT__Session__InterfaceName = "tun0";
    };
    volumes = [
      "/var/lib/qbittorrent:/config"
      "/var/lib/qbittorrent/Downloads:/downloads"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/gluetun 0750 root root -"
    "d /var/lib/qbittorrent 0750 qbittorrent media -"
    "d /var/lib/qbittorrent/Downloads 0775 qbittorrent media -"
    "d /mnt/storage/media 0775 root media -"
  ];

  users.groups.media = {
  };

  users.users.qbittorrent = {
    isSystemUser = true;
    group = "media";
    description = "qBittorrent User";
  };

  environment.systemPackages = with pkgs; [ wireguard-tools ];
  boot.kernelModules = [ "wireguard" ];
}
