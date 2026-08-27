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
    ../../modules/medialyze.nix
    ./networking.nix
    ../../modules/sure-generated.nix
    ../../modules/swiparr-generated.nix
    ../../modules/arr.nix
    ../../modules/ollama.nix
    ../../modules/flatpak.nix
    ../../modules/home-assistant.nix
    ../../modules/forgejo.nix
    ../../modules/tandoor.nix
    ../../modules/penpot-generated.nix
  ];

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernation.enable = false;
  systemd.targets.hybrid-sleep.enable = false;
  
  networking.hostName = "glacio";

  services.acpid.enable = true;

  power.ups = {
    enable = true;
    ups.cyberpower = {
      driver = "usbhid-ups";
      port = "auto";
      description = "CyberPower PR1500LCDRT2U";
    };
    users.homeassistant = {
      passwordFile = config.age.secrets."nut-password".path;
      upsmon = "primary";
    };
    upsmon.monitor.cyberpower = {
      system = "cyberpower@localhost";
      user = "homeassistant";
      passwordFile = config.age.secrets."nut-password".path;
      type = "primary";
      powerValue = 1;
    };
  };


  services.blueman.enable = true;

  environment.variables = {
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
  };

  boot.supportedFilesystems = [ "nfs" ];

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

  fileSystems."/mnt/desolo-media" = {
    device = "192.168.100.52:/mnt/data";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=600"
      "nofail"
    ];
  };

  jovian.steam = {
    enable = true;
    autoStart = true;
    desktopSession = "hyprland";
    user = config.mySystem.mainUser;
  };

  # Clean up temporary desktop session override files created by SteamOS/Jovian
  # when switching to desktop mode ("zzt-holo-temp-login.conf"). Otherwise,
  # SDDM will continue booting into Hyprland on subsequent reboots.
  systemd.services.display-manager.preStart = ''
    rm -f /etc/sddm.conf.d/zzt-holo-temp-login.conf /etc/sddm.conf.d/zzt-steamos-temp-login.conf
  '';

  nix.settings = {
    extra-substituters = [ "https://jovian-experiments.cachix.org" ];
    extra-trusted-public-keys = [ "jovian-experiments.cachix.org-1:TyDJIG9AdB5uEAHVAVCjXU1qKBZkCIvqj4rDRz5/sfY=" ];
  };

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [ 
    openssl 
    rocmPackages.rocm-smi 
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
  mySystem.illogical.scale = 1.5;

  security.sudo.extraRules = [
    {
      users = [ config.mySystem.mainUser ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl restart display-manager.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/systemctl restart display-manager.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  home-manager.users.${config.mySystem.mainUser} = {
    xdg.desktopEntries."return-to-gaming-mode" = {
      name = "Return to Gaming Mode";
      comment = "Exit desktop session and return to Steam Gaming Mode";
      exec = "sudo systemctl restart display-manager.service";
      icon = "steam";
      terminal = false;
      categories = [ "Game" ];
    };
  };

  myAppSets = {
    profile = "gaming";
    software_dev.enable = true;
  };



  mySystem.tailscale.enable = true;
  mySystem.flatpak.enable = true;
  mySystem.services = {
    jellyfin.enable = true;
    immich.enable = true;
    paperless.enable = true;
    arr.enable = true;
    ollama.enable = true;
    medialyze.enable = true;
    home-assistant.enable = true;
    forgejo.enable = true;
    tandoor.enable = true;
  };

  system.stateVersion = "25.11";

  systemd.services."docker-penpot-penpot-frontend" = {
    postStart = ''
      for i in $(seq 1 10); do
        if ${pkgs.docker}/bin/docker exec -u root penpot-penpot-frontend ln -sf /var/www/app/css/main.css /var/www/app/css/ui.css 2>/dev/null; then
          break
        fi
        sleep 1
      done
    '';
  };

  age.secrets."nut-password" = {
    file = ../../secrets/nut-password.age;
    mode = "0400";
    owner = "nutmon";
  };
}
