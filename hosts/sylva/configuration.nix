{ config, pkgs, illogical-flake, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../modules/nvidia.nix
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

  boot.supportedFilesystems = [ "ntfs3" ];

  fileSystems."/mnt/Random" = {
    device = "/dev/disk/by-uuid/20763881763859AC";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "nofail" "x-gvfs-show" "windows_names" ];
  };

  fileSystems."/mnt/GameDrive" = {
    device = "/dev/disk/by-uuid/3EBE91B1BE916267";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "nofail" "x-gvfs-show" "exec" "windows_names" ];
  };

  fileSystems."/mnt/Emulation" = {
    device = "/dev/disk/by-uuid/6498762D9875FE3C";
    fsType = "ntfs3";
    options = [ "rw" "uid=1000" "gid=100" "nofail" "x-gvfs-show" "exec" "windows_names" ];
  };

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = true;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
    myAppSets.development.enable = true;
    myAppSets.media.enable = true;
    myAppSets.games.enable = true;
    myAppSets.school.enable = true;
  };
  
  system.stateVersion = "25.11"; 
}
