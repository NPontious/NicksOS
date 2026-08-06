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
    software_dev = mkAppSet "software development tools";
    engineering = mkAppSet "engineering and electronics tools";
    gaming = mkAppSet "gaming emulators and tools";
    media = mkAppSet "media consumption and browsers";
    social = mkAppSet "communication tools";
    creativity = mkAppSet "content creation tools";
    documents = mkAppSet "document creation and editing";
    system_utils = mkAppSet "core system utilities";
  };

  config = lib.mkMerge [
    # Profiles
    (lib.mkIf (cfg.profile == "workstation") {
      myAppSets.software_dev.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
      myAppSets.documents.enable = lib.mkDefault true;
      myAppSets.system_utils.enable = lib.mkDefault true;
    })

    (lib.mkIf (cfg.profile == "gaming") {
      myAppSets.gaming.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
      myAppSets.system_utils.enable = lib.mkDefault true;
    })

    (lib.mkIf (cfg.profile == "laptop") {
      myAppSets.software_dev.enable = lib.mkDefault true;
      myAppSets.engineering.enable = lib.mkDefault true;
      myAppSets.media.enable = lib.mkDefault true;
      myAppSets.social.enable = lib.mkDefault true;
      myAppSets.documents.enable = lib.mkDefault true;
      myAppSets.system_utils.enable = lib.mkDefault true;
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

    (lib.mkIf cfg.software_dev.enable {
      virtualisation.docker.enable = lib.mkDefault true;
    })

    # Home Manager integration (pushing packages to the user)
    {
      home-manager.users.${config.mySystem.mainUser} = {
        home.packages = lib.mkMerge [
          (lib.mkIf cfg.software_dev.enable (with pkgs; [
            git gh gcc gnumake godot_4 docker-compose
          ] ++ cfg.software_dev.extraPackages))

          (lib.mkIf cfg.engineering.enable (with pkgs; [
            ltspice lc3tools logisim kicad freerouting
          ] ++ cfg.engineering.extraPackages))

          (lib.mkIf cfg.gaming.enable (with pkgs; [
            steam cemu dolphin-emu ryubing atlauncher heroic mangohud mangojuice waydroid wine-wayland eden steam-rom-manager
          ] ++ cfg.gaming.extraPackages))

          (lib.mkIf cfg.media.enable (with pkgs; [
            google-chrome jellyfin-mpv-shim
          ] ++ cfg.media.extraPackages))

          (lib.mkIf cfg.social.enable (with pkgs; [
            vesktop element-desktop
          ] ++ cfg.social.extraPackages))

          (lib.mkIf cfg.creativity.enable (with pkgs; [
            blender inkscape gimp obs-studio
          ] ++ cfg.creativity.extraPackages))

          (lib.mkIf cfg.documents.enable (with pkgs; [
            libreoffice-fresh xournalpp pdfarranger typst tinymist
          ] ++ cfg.documents.extraPackages))

          (lib.mkIf cfg.system_utils.enable (with pkgs; [
            kdePackages.dolphin kdePackages.konsole kdePackages.filelight libqalculate sshpass
          ] ++ cfg.system_utils.extraPackages))
        ];

        programs.vscode = lib.mkIf cfg.software_dev.enable {
          enable = true;
          package = pkgs.vscode;
        };
      };
    }
  ];
}
