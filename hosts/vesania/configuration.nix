{ config, pkgs, illogical-flake, hyprland, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../common.nix
  ];
  
  services.hardware.bolt.enable = true;
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];

  boot.resumeDevice = "/dev/disk/by-uuid/c02199a3-33fe-4688-a447-299bcd69417c";

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";  
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30m";

  networking.hostName = "vesania";
  networking.networkmanager.wifi.powersave = false;

  services.blueman.enable = true;
  services.displayManager.ly.enable = true;

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = true;
  services.upower.enable = true;
  services.geoclue2.enable = true;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
    myAppSets.development.enable = true;
    myAppSets.media.enable = true;
    myAppSets.school.enable = true;
  };

  system.stateVersion = "25.11"; 
}
