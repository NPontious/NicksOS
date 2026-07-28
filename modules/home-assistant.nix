{ config, lib, pkgs, ha-fordpass, ... }:

let
  fordpass-pkg = pkgs.buildHomeAssistantComponent {
    owner = "marq24";
    domain = "fordpass";
    version = "flake";
    src = ha-fordpass;
  };
in

{
  options.mySystem.services.home-assistant.enable = lib.mkEnableOption "Home Assistant";

  config = lib.mkIf config.mySystem.services.home-assistant.enable {
    services.home-assistant = {
      enable = true;
      customComponents = [
        fordpass-pkg
      ];
      extraComponents = [
        "default_config"
        "met"
        "esphome"
        "radio_browser"
        "sonarr"
        "radarr"
        "jellyfin"
        "lidarr"
        "steam_online"
        "tailscale"
        "qbittorrent"
        "ollama"
        "immich"
        "paperless_ngx"
        "google"
      ];
      config = {
        default_config = {};
      };
    };
  };
}
