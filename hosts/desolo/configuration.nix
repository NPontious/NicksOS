{ config, pkgs, illogical-flake, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
  ];

  networking.hostName = "desolo";

  services.hardware.bolt.enable = true;

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = false;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
  };

  system.stateVersion = "25.11"; 
}
