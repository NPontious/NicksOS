{ config, lib, pkgs, ... }:

let
  cfg = config.myAppSets;

  # Helper to create a standard app set option
  mkAppSet = description: {
    enable = lib.mkEnableOption description;
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Extra packages to add to the ${description} set.";
    };
  };
in
{
  options.myAppSets = {
    profile = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "workstation" "gaming" "server" "laptop" ]);
      default = null;
      description = "Pre-defined profile to enable multiple app sets at once.";
    };
    development = mkAppSet "development tools";
    school = mkAppSet "school software";
    gaming = mkAppSet "gaming emulators and tools";
    media = mkAppSet "media consumption and browsers";
    social = mkAppSet "communication tools";
    creativity = mkAppSet "content creation tools";
    productivity = mkAppSet "office and productivity tools";
  };

  config = lib.mkMerge [
    # Profiles
    (lib.mkIf (cfg.profile == "workstation") {
      myAppSets.development.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
      myAppSets.productivity.enable = lib.mkDefault true;
    })

    (lib.mkIf (cfg.profile == "gaming") {
      myAppSets.gaming.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
    })

    (lib.mkIf (cfg.profile == "laptop") {
      myAppSets.development.enable = lib.mkDefault true;
      myAppSets.school.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
      myAppSets.productivity.enable = lib.mkDefault true;
    })

    # System-level integrations
    (lib.mkIf cfg.gaming.enable {
      programs.steam.enable = true;
      programs.gamemode.enable = true;

      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if ((action.id == "com.feralinteractive.GameMode.governor-helper" ||
               action.id == "com.feralinteractive.GameMode.gpu-helper" ||
               action.id == "com.feralinteractive.GameMode.cpu-helper" ||
               action.id == "com.feralinteractive.GameMode.procsys-helper") &&
              subject.isInGroup("gamemode")) {
            return polkit.Result.YES;
          }
        });
      '';
    })

    (lib.mkIf cfg.development.enable {
      virtualisation.docker.enable = lib.mkDefault true;
    })

    # Home Manager integration (pushing packages to the user)
    {
      home-manager.users.${config.mySystem.mainUser} = {
        home.packages = lib.mkMerge [
          (lib.mkIf cfg.development.enable (with pkgs; [
            git gh gcc gnumake godot_4 typst tinymist docker-compose
          ] ++ cfg.development.extraPackages))

          (lib.mkIf cfg.school.enable (with pkgs; [
            ltspice sshpass lc3tools logisim
          ] ++ cfg.school.extraPackages))

          (lib.mkIf cfg.gaming.enable (with pkgs; [
            steam cemu dolphin-emu ryubing atlauncher heroic mangohud mangojuice waydroid wine-wayland
          ] ++ cfg.gaming.extraPackages))

          (lib.mkIf cfg.media.enable (with pkgs; [
            google-chrome kdePackages.dolphin kdePackages.konsole kdePackages.filelight libqalculate
          ] ++ cfg.media.extraPackages))

          (lib.mkIf cfg.social.enable (with pkgs; [
            vesktop element-desktop
          ] ++ cfg.social.extraPackages))

          (lib.mkIf cfg.creativity.enable (with pkgs; [
            blender inkscape gimp obs-studio
          ] ++ cfg.creativity.extraPackages))

          (lib.mkIf cfg.productivity.enable (with pkgs; [
            libreoffice-fresh xournalpp pdfarranger
          ] ++ cfg.productivity.extraPackages))
        ];

        programs.vscode = lib.mkIf cfg.development.enable {
          enable = true;
          package = pkgs.vscode;
        };
      };
    }
  ];
}
