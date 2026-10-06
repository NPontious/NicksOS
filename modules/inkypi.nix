{ config, lib, pkgs, ... }:

let
  cfg = config.mySystem.services.inkypi;
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    flask
    python-dotenv
    requests
    pillow
    waitress
    psutil
    pytz
    icalendar
    feedparser
    astral
    numpy
    recurring-ical-events
  ]);
in
{
  options.mySystem.services.inkypi = {
    enable = lib.mkEnableOption "InkyPi E-Paper Image Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      description = "Port to expose the InkyPi web interface on.";
    };
    packageDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/nicho/InkyPi";
      description = "Location of the InkyPi repository checkout.";
    };
    user = lib.mkOption {
      type = lib.types.str;
      default = "nicho";
      description = "User account under which to run the service.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    systemd.services.inkypi = {
      description = "InkyPi E-Paper Image Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = {
        PYTHONPATH = "src";
        PORT = toString cfg.port;
      };

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        WorkingDirectory = cfg.packageDir;
        ExecStart = "${pythonEnv}/bin/python3 src/inkypi.py --dev --port ${toString cfg.port} --host 0.0.0.0";
        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
