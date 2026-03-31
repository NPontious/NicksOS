{ config, lib, pkgs, ... }:

let
  cfg = config.myAppSets;
in
{
  options.myAppSets = {
    development.enable = lib.mkEnableOption "development tools";
    school.enable = lib.mkEnableOption "school software";
    games.enable = lib.mkEnableOption "gaming emulators";
    media.enable = lib.mkEnableOption "media and browser tools";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.development.enable {
      home.packages = with pkgs; [ git gh vscode gcc gnumake godot_4 typst tinymist ];
    })

    (lib.mkIf cfg.school.enable {
      home.packages = with pkgs; [ ltspice sshpass lc3tools logisim ];
    })

    (lib.mkIf cfg.games.enable {
      home.packages = with pkgs; [ cemu dolphin-emu ryubing steam ];
    })

    (lib.mkIf cfg.media.enable {
      home.packages = with pkgs; [ google-chrome kdePackages.dolphin kdePackages.konsole kdePackages.filelight packagekit vesktop blender inkscape xournalpp libreoffice-fresh libqalculate ];
    })
  ];
}
