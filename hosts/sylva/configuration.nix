{ config, pkgs, illogical-flake, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../common.nix
  ];
  
  networking.hostName = "sylva";

  nixpkgs.overlays = [
    (final: prev: {
      btop = prev.btop.override { cudaSupport = true; };
    })
  ];

  services.blueman.enable = true;
  services.displayManager.ly.enable = true;

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = true;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
    myAppSets.development.enable = true;
    myAppSets.media.enable = true;
    myAppSets.games.enable = true;
  };
  
  system.stateVersion = "25.11"; 
}
