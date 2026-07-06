{ config, lib, pkgs, ... }:

{
  options.mySystem.services.medialyze = {
    enable = lib.mkEnableOption "MediaLyze Media Analyzer";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8083;
      description = "Port to expose the MediaLyze web interface on.";
    };
    mediaDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/storage";
      description = "Path to the media storage directory to mount into MediaLyze.";
    };
  };

  config = lib.mkIf config.mySystem.services.medialyze.enable {
    systemd.tmpfiles.rules = [
      "d /var/lib/medialyze 0750 root ${config.mySystem.mediaGroup} -"
    ];

    virtualisation.oci-containers.containers.medialyze = {
      image = "ghcr.io/npontious/medialyze:dev";
      environment = {
        TZ = config.time.timeZone;
      };
      ports = [
        "${toString config.mySystem.services.medialyze.port}:8080"
      ];
      volumes = [
        "/var/lib/medialyze:/config"
        "${config.mySystem.services.medialyze.mediaDir}:/media:ro"
      ];
    };
  };
}
