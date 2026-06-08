{ config, lib, pkgs, nix-flatpak, ... }:

{
  imports = [
    nix-flatpak.nixosModules.nix-flatpak
  ];

  services.flatpak = {
    enable = true;
    
    # This automatically uninstalls Flatpaks when you remove them from this list
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
}
