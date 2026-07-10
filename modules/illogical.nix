{ config, lib, pkgs, illogical-flake, ... }:

let
  cfg = config.mySystem.illogical;
in
{
  options.mySystem.illogical = {
    enableShell = lib.mkEnableOption "headless shell";
    enableDesktop = lib.mkEnableOption "desktop environment";
    scale = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.int lib.types.float);
      default = null;
      description = "Convenience option: UI scale factor for fallback/all monitors (e.g. 1, 1.25, 1.5, 2).";
    };
    monitors = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          output = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Monitor output name (e.g. 'HDMI-A-1', 'eDP-1', or '' for all/fallback).";
          };
          mode = lib.mkOption {
            type = lib.types.str;
            default = "preferred";
            description = "Resolution and refresh rate (e.g. 'preferred', '3840x2160@60', 'highrr').";
          };
          position = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Monitor position (e.g. 'auto', '0x0').";
          };
          scale = lib.mkOption {
            type = lib.types.either lib.types.int lib.types.float;
            default = 1;
            description = "UI scale factor (e.g. 1, 1.25, 1.5, 2).";
          };
        };
      });
      default = [];
      description = "Declarative monitor configurations generated into ~/.config/hypr/monitors.lua.";
    };
    extraConfigLua = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra Lua code to append to ~/.config/hypr/monitors.lua (or custom rules/config).";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enableShell || cfg.enableDesktop) {

      programs.dconf.enable = cfg.enableDesktop;

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";

      environment.pathsToLink = [ "/share/applications" "/share/xdg-desktop-portal" ];

      home-manager.users.${config.mySystem.mainUser} = {
        imports = [ illogical-flake.homeManagerModules.default ];
        programs.illogical-impulse.enable = true;
        home.stateVersion = "24.05";
        
        dconf.enable = cfg.enableDesktop;
        
      };
    })

    (lib.mkIf cfg.enableShell {
      home-manager.users.${config.mySystem.mainUser}.programs.illogical-impulse.dotfiles = {
        fish.enable = true;
        starship.enable = true;
      };
    })

    (lib.mkIf cfg.enableDesktop {
      programs.hyprland.enable = true;
      
      home-manager.users.${config.mySystem.mainUser} = {
        programs.illogical-impulse.dotfiles.kitty.enable = true;
        
        qt.platformTheme.name = lib.mkForce "kde";
        
        services.hypridle.enable = lib.mkForce false;

        home.pointerCursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };

        programs.illogical-impulse.hyprland = {
          monitors = if cfg.monitors != [] then cfg.monitors
                     else if cfg.scale != null then [ { output = ""; mode = "preferred"; position = "auto"; scale = cfg.scale; } ]
                     else [];
          extraConfigLua = cfg.extraConfigLua;
        };
      };
    })
  ];
}
