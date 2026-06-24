{ config, pkgs, lib, agenix, ... }:

{
  options.mySystem = {
    mainUser = lib.mkOption {
      type = lib.types.str;
      default = "nicho";
      description = "The primary user of the system.";
    };
    mediaGroup = lib.mkOption {
      type = lib.types.str;
      default = "media";
      description = "The group used for media-related services.";
    };
  };

  imports = [
    ./modules/secrets.nix
    ./modules/pkg-sets.nix
  ];

  config = {
    time.timeZone = "America/New_York";
    i18n.defaultLocale = "en_US.UTF-8";

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.supportedFilesystems = [ "btrfs" ];
    boot.kernelPackages = pkgs.linuxPackages; 

    networking.networkmanager.enable = true;

    services.openssh = {
      enable = true;
      openFirewall = false;
    };

    nixpkgs.config.allowUnfree = true;

    environment.shellAliases = {
      config = "sudo nano /etc/nixos/hosts/${config.networking.hostName}/configuration.nix";
      build = "sudo nixos-rebuild switch --flake '/etc/nixos#${config.networking.hostName}'";
    };

    programs.fish.enable = true;

    users.groups.${config.mySystem.mediaGroup} = { };

    users.users.${config.mySystem.mainUser} = {
      isNormalUser = true;
      description = config.mySystem.mainUser;
      extraGroups = [ "networkmanager" "wheel" "video" "input" "render" "docker" "gamemode" config.mySystem.mediaGroup ];
      shell = pkgs.fish;
    };

    home-manager.users.${config.mySystem.mainUser} = {
      imports = [
        ./modules/home-manager-common.nix
      ];
    };

    environment.systemPackages = with pkgs; [ 
      kitty tree git net-tools wget curl
      agenix.packages.${pkgs.system}.default
    ];
  };
}
