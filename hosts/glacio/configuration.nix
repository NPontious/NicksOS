{ config, pkgs, illogical-flake, hyprland, lib, inky-combo, ... }:

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
    ../../modules/inkypi.nix
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
      "soft"
      "timeo=30"
      "retrans=2"
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
  mySystem.distributedBuilds.enable = true;
  mySystem.services = {
    jellyfin.enable = true;
    immich = {
      enable = true;
      shareProxy.enable = true;
    };
    paperless.enable = true;
    arr.enable = true;
    ollama.enable = true;
    medialyze = {
      enable = true;
      mediaDir = "/mnt/desolo-media";
    };
    home-assistant.enable = true;
    forgejo.enable = true;
    tandoor.enable = true;
    inkypi = {
      enable = true;
      port = 8085;
      environmentFile = config.age.secrets."inkypi-env".path;
      extraPlugins = [ inky-combo ];
      settings = {
        name = "Glacio PhotoFrame";
        display_type = "photoframe";
        model = "waveshare_13_3";
        resolution = [ 1600 1200 ];
        orientation = 0;
        playlist_config = {
          playlists = [
            {
              name = "Default";
              start_time = "00:00";
              end_time = "24:00";
              plugins = [
                {
                  id = "dashboard";
                  settings = {
                    "calendarURLs[]" = [
                      "$CALENDAR_URL_1"
                      "$CALENDAR_URL_2"
                    ];
                    "calendarColors[]" = [
                      "#3b82f6"
                      "#10b981"
                    ];
                    timezone = "America/New_York";
                    weatherLayout = "none";
                    slot3Widget = "none";
                  };
                  refresh_settings = {
                    interval = 30;
                    unit = "minutes";
                  };
                }
              ];
            }
          ];
        };
      };
    };
  };

  system.stateVersion = "25.11";

  systemd.services.photoframe-auto-rotate = {
    description = "Auto-rotate PhotoFrame on connect";
    wantedBy = [ "multi-user.target" ];
    after = [ "hostapd.service" "network.target" ];
    path = [ pkgs.hostapd pkgs.iputils pkgs.curl pkgs.coreutils ];
    script = let
      triggerScript = pkgs.writeShellScript "photoframe-trigger.sh" ''
        IFNAME="$1"
        EVENT="$2"
        echo "photoframe-auto-rotate event received on $IFNAME: $EVENT"
        case "$EVENT" in
          AP-STA-CONNECTED*)
            MAC="''${EVENT#* }"
            echo "Station $MAC connected to $IFNAME, polling web server on 192.168.101.65..."
            (
              IP="192.168.101.65"
              EXPECTED_URL="http://192.168.101.1:8085/api/photoframe/image"
              for i in $(seq 1 45); do
                sleep 2
                CFG=$(curl -s --connect-timeout 2 --max-time 5 "http://$IP/api/config" || true)
                if [ -n "$CFG" ]; then
                  echo "Station HTTP server online! Config: $CFG"
                  BAT=$(curl -s --connect-timeout 2 --max-time 5 "http://$IP/api/battery" || true)
                  echo "Station Battery Telemetry: $BAT"
                  curl -s --connect-timeout 2 --max-time 5 -X PATCH "http://$IP/api/config"                     -H "Content-Type: application/json"                     -d "{\"rotation_mode\":\"url\",\"image_url\":\"$EXPECTED_URL\"}" || true
                  echo "Sending POST /api/rotate..."
                  RESP=$(curl -s -S --connect-timeout 5 --max-time 45 -w "
HTTP_STATUS:%{http_code}" -X POST "http://$IP/api/rotate" 2>&1 || true)
                  echo "Rotate response: $RESP"
                  exit 0
                fi
                echo "Attempt $i: waiting for http://$IP/api/config..."
              done
              echo "Station $IP did not respond with HTTP server within 90s."
            ) &
            ;;
        esac
      '';
    in ''
      exec hostapd_cli -i ap0 -a ${triggerScript}
    '';
    serviceConfig = {
      Restart = "always";
      RestartSec = "5s";
    };
  };

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

  age.secrets."hostapd-inkypi-password" = {
    file = ../../secrets/hostapd-inkypi-password.age;
    mode = "0400";
  };

  age.secrets."inkypi-env" = {
    file = ../../secrets/inkypi-env.age;
    mode = "0400";
    owner = "inkypi";
    group = "inkypi";
  };
}
