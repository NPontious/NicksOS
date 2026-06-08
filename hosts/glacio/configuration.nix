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

  fileSystems."/mnt/storage" = {
   device = "/dev/disk/by-uuid/1bf904ce-54cf-4bf2-8193-f92266d1655a";
   fsType = "btrfs";
   options = [ 
     "defaults" 
     "compress=zstd"
     "x-systemd.automount"
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
    google-chrome kdePackages.dolphin 
    cemu ryubing dolphin-emu atlauncher waydroid heroic 
    mangohud mangojuice rocmPackages.rocm-smi 
    cifs-utils 
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

  myAppSets = {
    profile = "gaming";
    development.enable = true;
  };

  home-manager.users.nicho = {
    imports = [
      ../../modules/home-manager-common.nix
    ];
  };

  system.stateVersion = "25.11"; 
}
