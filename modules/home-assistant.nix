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
        "panel_custom"
      ];
      config = {
        default_config = {};
        frontend = {
          themes = "!include_dir_merge_named themes";
          extra_module_url = [
            "/hacsfiles/material-you-utilities/material-you-utilities.min.js"
          ];
        };
        panel_custom = [
          {
            name = "material-you-panel";
            url_path = "material-you-configuration";
            sidebar_title = "Material You Utilities";
            sidebar_icon = "mdi:material-design";
            module_url = "/hacsfiles/material-you-utilities/material-you-utilities.min.js";
          }
        ];
      };
    };
  };
}
