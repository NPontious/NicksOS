{ config, lib, pkgs, inkypi, ... }:

let
  cfg = config.mySystem.services.inkypi;
in
{
  imports = [ inkypi.nixosModules.default ];

  options.mySystem.services.inkypi = {
    enable = lib.mkEnableOption "InkyPi E-Paper Image Server";
    port = lib.mkOption {
      type = lib.types.port;
      default = 8085;
      description = "Port to expose the InkyPi web interface on.";
    };
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = { };
      description = "Declarative InkyPi device configuration matching device.json.";
    };
    extraPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ];
      description = "Additional plugin directories to load.";
    };
    extraPythonPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = ps: [ ];
      description = "Extra Python packages to make available for community plugins.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional environment file (e.g. from agenix/sops-nix) for API keys.";
    };
    chromiumPackage = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = pkgs.chromium;
      description = "Chromium package for rendering HTML-based plugins.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.inkypi = {
      enable = true;
      port = cfg.port;
      settings = cfg.settings;
      extraPlugins = cfg.extraPlugins;
      extraPythonPackages = cfg.extraPythonPackages;
      environmentFile = cfg.environmentFile;
      chromiumPackage = cfg.chromiumPackage;
    };
  };
}
