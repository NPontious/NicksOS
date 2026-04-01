{ config, pkgs, illogical-flake, hyprland, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../common.nix
    ../../modules/jellyfin.nix
    ../../modules/immich.nix
    ../../modules/paperless.nix
    ./networking.nix
    ../../modules/sure-generated.nix
    ../../modules/arr.nix
    ../../modules/ollama.nix
  ];

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernation.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  
  networking.hostName = "glacio";

  services.blueman.enable = true;

  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  };

  fileSystems."/mnt/smbshare" = {
   device = "//192.168.1.101/Share";
   fsType = "cifs";
   options = [
     "guest"
     "iocharset=utf8"
     "vers=3.1.1"
     "uid=1000"
     "gid=100"
     "x-systemd.automount"
     "noatime"
     "nofail"
   ];
  };

  fileSystems."/mnt/storage" = {
   device = "/dev/disk/by-uuid/1bf904ce-54cf-4bf2-8193-f92266d1655a";
   fsType = "btrfs";
   options = [ 
     "defaults" 
     "compress=zstd"
     "nofail"
   ];
  };

  jovian.steam = {
    enable = true;
    autoStart = true;
    desktopSession = "hyprland";
    user = "nicho";
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ 
    kitty tree git net-tools swww steam-rom-manager openssl 
    cifs-utils google-chrome kdePackages.dolphin 
    cemu ryubing dolphin-emu atlauncher waydroid heroic 
    gamemode mangohud mangojuice rocmPackages.rocm-smi 
    smartmontools appimage-run btrfs-progs 
  ];

  nixpkgs.overlays = [
    (final: prev: {
      btop = prev.btop.override { rocmSupport = true; };

      inputplumber = prev.inputplumber.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ final.nix-prefetch-git ];
      });
    })
  ];

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = true;

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
    myAppSets.development.enable = true;
    myAppSets.games.enable = true;
    myAppSets.media.enable = true;
  };

  system.stateVersion = "25.11"; 
}
