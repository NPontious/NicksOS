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
    ./modules/distributed-builds.nix
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
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages; 

    networking.networkmanager.enable = true;

    networking.hosts = {
      "100.85.234.127" = [ "glacio" "glacio.tail4a2d4d.ts.net" ];
      "100.88.181.11" = [ "sylva" "sylva.tail4a2d4d.ts.net" ];
      "100.126.152.28" = [ "desolo" "desolo.tail4a2d4d.ts.net" ];
    };

    networking.getaddrinfo = {
      enable = true;
      precedence = {
        "::ffff:0:0/96" = 100;
        "::/0" = 40;
        "::1/128" = 50;
        "::/96" = 20;
        "2002::/16" = 30;
      };
    };

    services.openssh = {
      enable = true;
      openFirewall = false;
    };

    services.udev.extraRules = ''
      ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", RUN+="${pkgs.hdparm}/bin/hdparm -S 180 /dev/%k"
    '';

    # Disk health monitoring. "-n standby,q" skips checks on spun-down disks so
    # smartd doesn't undo the spindown above. Weekly short / monthly long self-tests.
    services.smartd = {
      enable = true;
      defaults.autodetected = "-a -n standby,q -s (S/../../7/03|L/../01/./04)";
    };

    nixpkgs.config.allowUnfree = true;

    environment.shellAliases = {
      config = "sudo nano /etc/nixos/hosts/${config.networking.hostName}/configuration.nix";
    };

    programs.fish.enable = true;

    users.groups.${config.mySystem.mediaGroup} = { };

    users.users.${config.mySystem.mainUser} = {
      isNormalUser = true;
      description = config.mySystem.mainUser;
      extraGroups = [ "networkmanager" "wheel" "video" "input" "render" "docker" "gamemode" "lp" "scanner" config.mySystem.mediaGroup ];
      shell = pkgs.fish;
    };

    home-manager.users.${config.mySystem.mainUser} = {
      imports = [
        ./modules/home-manager-common.nix
      ];
    };

    environment.systemPackages = with pkgs; [ 
      kitty tree git net-tools wget curl antigravity-cli claude-code
      agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      (writeShellScriptBin "build" ''
        BUILD_HOST_ARGS=()
        ARGS=()
        for arg in "$@"; do
          if [ "$arg" = "-r" ]; then
            BUILD_HOST_ARGS=(--build-host sylva)
          else
            ARGS+=("$arg")
          fi
        done
        exec sudo nixos-rebuild switch --flake "/etc/nixos#${config.networking.hostName}" "''${BUILD_HOST_ARGS[@]}" "''${ARGS[@]}"
      '')
    ];
  };
}
