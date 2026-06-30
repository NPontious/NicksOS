{ config, lib, pkgs, illogical-flake, ... }:

let
  cfg = config.mySystem.illogical;
in
{
  options.mySystem.illogical = {
    enableShell = lib.mkEnableOption "headless shell";
    enableDesktop = lib.mkEnableOption "desktop environment";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enableShell || cfg.enableDesktop) {
      # We removed the manual Python overlay because the 'ye' fork 
      # manages its own isolated python environment for color switching.

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
        
        # NOTE: dolphinrc is now managed as a mutable file by the 'ye' flake,
        # so we no longer need the 'enable = false' hack.
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
        
        # The 'ye' fork sets up qt6ct/kvantum. If you prefer the standard KDE
        # theme engine, you can keep this, but 'ye' is designed for qt6ct.
        qt.platformTheme.name = lib.mkForce "kde";
        
        services.hypridle.enable = lib.mkForce false;

        home.pointerCursor = {
          name = "Bibata-Modern-Ice";
          package = pkgs.bibata-cursors;
          size = 24;
          gtk.enable = true;
          x11.enable = true;
        };

        # You can now add any Hyprland overrides here declaratively.
        # These will be merged with the dotfiles' Lua configuration.
        wayland.windowManager.hyprland.settings = {
          # Example:
          # monitor = [ ",highrr,auto,1" ];
        };
      };
    })
  ];
}
