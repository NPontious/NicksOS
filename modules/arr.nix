{ config, pkgs, ... }:

{
  services.sonarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.lidarr = {
    enable = true;
    group = "media";
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
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
      "8081:8081/tcp"
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
    };
    volumes = [
      "/var/lib/qbittorrent:/config"
      "/var/lib/qbittorrent/Downloads:/downloads"
    ];
  };

  # Open firewall for the exposed ports on Gluetun
  networking.firewall.allowedTCPPorts = [ 8081 55000 ];
  networking.firewall.allowedUDPPorts = [ 55000 ];

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
