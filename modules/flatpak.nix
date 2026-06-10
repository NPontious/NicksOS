{ config, lib, pkgs, nix-flatpak, ... }:

{
  options.mySystem.flatpak.enable = lib.mkEnableOption "Flatpak Support";

  imports = [
    nix-flatpak.nixosModules.nix-flatpak
  ];

  config = lib.mkIf config.mySystem.flatpak.enable {
    services.flatpak = {
      enable = true;
      uninstallUnmanaged = true;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
      ];
      packages = [
        "org.vinegarhq.Sober"
      ];
    };
  };
}
