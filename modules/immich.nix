{ config, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /mnt/storage/Pictures/immich 0750 immich immich -"
  ];

  services.immich = {
    enable = true;
    port = 2283;
    mediaLocation = "/mnt/storage/Pictures/immich";
    host = "0.0.0.0";
    database.passwordFile = config.age.secrets."postgres-password".path;
    #openFirewall = true;
    package = pkgs.immich;
  };
}
