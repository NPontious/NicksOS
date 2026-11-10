{ config, lib, pkgs, bank-alert-bridge, ... }:

let
  cfg = config.mySystem.services.bank-alert-bridge;
in
{
  imports = [ bank-alert-bridge.nixosModules.default ];

  options.mySystem.services.bank-alert-bridge = {
    enable = lib.mkEnableOption "Bank Alert Bridge";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8088;
      description = "Port to expose the Bank Alert Bridge API.";
    };

    environmentFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the secret environment file (from agenix).";
    };
  };

  config = lib.mkIf cfg.enable {
    services.bank-alert-bridge = {
      enable = true;
      port = cfg.port;
      dataDir = "/var/lib/bank-alert-bridge";
      environmentFile = cfg.environmentFile;
      imap.enable = true;
    };
  };
}
