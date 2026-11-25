{ config, pkgs, lib, agenix, ... }:

let
  codex = pkgs.stdenv.mkDerivation {
    pname = "codex";
    version = "0.169.0";
    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v0.169.0/codex-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-mvTXUfzhg/rt6mKUN9UlLb9FjusEEwz0+XvoRGIeqYU=";
    };
    sourceRoot = ".";
    installPhase = "install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex";
  };
in
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

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "@wheel" config.mySystem.mainUser ];
    };

    nix.extraOptions = ''
      !include /home/${config.mySystem.mainUser}/.config/nix/nix.conf
    '';

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
      "100.88.181.11" = [ "sylva" ];
      "100.126.152.28" = [ "desolo" ];
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

    programs.fish = {
      enable = true;
      shellInit = ''
        if not set -q XDG_RUNTIME_DIR
          set -gx XDG_RUNTIME_DIR /run/user/(id -u)
        end
      '';
    };

    # Pinned: NFS between glacio and desolo compares numeric IDs.
    users.groups.${config.mySystem.mediaGroup}.gid = 983;

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
      kitty tree git net-tools wget curl mosh antigravity-cli claude-code opencode codex
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
        EXTRA_OPTS=()
        if [ -f "$HOME/.config/nix/nix.conf" ]; then
          TOKEN=$(grep -E '^\s*access-tokens\s*=' "$HOME/.config/nix/nix.conf" | sed -E 's/^\s*access-tokens\s*=\s*//')
          if [ -n "$TOKEN" ]; then
            EXTRA_OPTS+=(--option access-tokens "$TOKEN")
          fi
        fi
        exec sudo nixos-rebuild switch --flake "/etc/nixos#${config.networking.hostName}" "''${EXTRA_OPTS[@]}" "''${BUILD_HOST_ARGS[@]}" "''${ARGS[@]}"
      '')
    ];
  };
}
