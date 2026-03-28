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
      nixpkgs.overlays = [
        (final: prev: {
          pythonPackagesExtensions = (prev.pythonPackagesExtensions or []) ++ [
            (python-final: python-prev: 
              if python-prev ? kde-material-you-colors then {
                kde-material-you-colors = python-prev.kde-material-you-colors.overridePythonAttrs (old: {
                  dependencies = (old.dependencies or []) ++ [ python-prev.python-magic ];
                  propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ python-prev.python-magic ];
                });
              } else {}
            )
          ];

          kde-material-you-colors = prev.kde-material-you-colors.overridePythonAttrs (old: {
            dependencies = (old.dependencies or []) ++ [ prev.python3Packages.python-magic ];
            propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ prev.python3Packages.python-magic ];
          });
        })
      ];

      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "bak";

      home-manager.users.nicho = {
        imports = [ illogical-flake.homeManagerModules.default ];
        programs.illogical-impulse.enable = true;
        home.stateVersion = "24.05";
      };
    })

    (lib.mkIf cfg.enableShell {
      home-manager.users.nicho.programs.illogical-impulse.dotfiles = {
        fish.enable = true;
        starship.enable = true;
      };
    })

    (lib.mkIf cfg.enableDesktop {
      programs.hyprland.enable = true;
      home-manager.users.nicho = {
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

        wayland.windowManager.hyprland.settings = {
          exec-once = [ "kitty" "hyprctl setcursor Bibata-Modern-Ice 24" ];
          monitor = [ ",preferred,auto,1" ];
          env = [ "XCURSOR_THEME,Bibata-Modern-Ice" "XCURSOR_SIZE,24" ];
          misc = {
            vrr = 0;                  
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };
        };
      };
    })
  ];
}
