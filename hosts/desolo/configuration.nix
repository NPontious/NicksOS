{ config, pkgs, illogical-flake, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../modules/intel.nix
  ];

  networking.hostName = "desolo";

  services.hardware.bolt.enable = true;
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "i915" ];

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = false;

  myAppSets.profile = "server";

  mySystem.tailscale.enable = true;
  mySystem.hardware.intel.enable = true;

  system.stateVersion = "25.11"; 
}
