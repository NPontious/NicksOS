{ config, lib, pkgs, ... }:

{
  options.mySystem.services.immich.enable = lib.mkEnableOption "Immich Photo Management";

  config = lib.mkIf config.mySystem.services.immich.enable {
    systemd.tmpfiles.rules = [
      "d /mnt/storage/Pictures/immich 0750 immich immich -"
    ];

    services.immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/mnt/storage/Pictures/immich";
      host = "0.0.0.0";
      package = pkgs.immich;
    };
  };
}
