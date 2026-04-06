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
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = false;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
  };

  system.stateVersion = "25.11"; 
}
