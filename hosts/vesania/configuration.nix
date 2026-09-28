{ config, pkgs, illogical-flake, hyprland, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../modules/flatpak.nix
    ../../modules/intel.nix
    ../../common.nix
  ];
  
  virtualisation.docker.enable = true;
  virtualisation.waydroid.enable = true;

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      zlib
      zstd
      stdenv.cc.cc.lib
    ];
  };

  environment.systemPackages = with pkgs; [
    android-tools
  ];

  services.hardware.bolt.enable = true;
  services.fwupd.enable = true;
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "i915" ];

  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.resumeDevice = "/dev/disk/by-uuid/c02199a3-33fe-4688-a447-299bcd69417c";

  boot.kernelParams = [ "nokaslr" "pcie_aspm=force" ];

  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x51f0", ATTR{d3cold_allowed}="0"
  '';

  services.logind.settings.Login.HandleLidSwitch = "suspend";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "suspend";

  networking.hostName = "vesania";
  networking.networkmanager.wifi.powersave = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.blueman.enable = true;
  services.displayManager.ly.enable = true;

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = true;
  mySystem.illogical.scale = 1;
  services.upower.enable = true;
  services.geoclue2.enable = true;

  # Printing & Scanning Support
  services.printing = {
    enable = true;
    drivers = with pkgs; [ hplip ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.ipp-usb.enable = true;

  myAppSets = {
    profile = "laptop";
    gaming.enable = true;
  };

  mySystem.tailscale.enable = true;
  mySystem.flatpak.enable = true;
  mySystem.hardware.intel.enable = true;
  mySystem.distributedBuilds.enable = true;

  system.stateVersion = "25.11"; 
}
