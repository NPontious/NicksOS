{ config, lib, pkgs, ... }:

{
  options.mySystem.services.immich = {
    enable = lib.mkEnableOption "Immich Photo Management";

    shareProxy = {
      enable = lib.mkEnableOption "Immich Public Share Proxy via Tailscale Funnel";

      tailscaleHostname = lib.mkOption {
        type = lib.types.str;
        default = "photos-share";
        description = "Tailscale machine name for the public share proxy";
      };

      tailnet = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Tailnet domain suffix. If null, PUBLIC_BASE_URL should be set in the tailscale-share-env secret.";
      };

      dns = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Optional DNS resolvers for the Tailscale container. If empty, uses UPSTREAM_DNS from tailscale-share-env secret or auto-detects from network DHCP.";
      };
    };
  };

  config = let
    cfg = config.mySystem.services.immich;
    shareCfg = cfg.shareProxy;
    fqdn = if shareCfg.tailnet != null
      then "${shareCfg.tailscaleHostname}.${shareCfg.tailnet}"
      else null;

    tailscaleServeConfig = pkgs.writeText "serve.json" (builtins.toJSON {
      TCP."443".HTTPS = true;
      Web."\${TS_CERT_DOMAIN}:443".Handlers."/".Proxy = "http://127.0.0.1:3000";
      AllowFunnel."\${TS_CERT_DOMAIN}:443" = true;
    });
  in lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d /mnt/storage/Pictures/immich 0750 immich immich -"
    ] ++ lib.optionals shareCfg.enable [
      "d /var/lib/tailscale-immich-share 0700 root root -"
      "d /run/tailscale-immich-share 0755 root root -"
    ];

    services.immich = {
      enable = true;
      port = 2283;
      mediaLocation = "/mnt/storage/Pictures/immich";
      host = "0.0.0.0";
      package = pkgs.immich;
    };

    age.secrets."tailscale-share-env" = lib.mkIf shareCfg.enable {
      file = ../secrets/tailscale-share-env.age;
      mode = "0400";
    };

    virtualisation.oci-containers.containers = lib.mkIf shareCfg.enable {
      tailscale-immich-share = {
        image = "tailscale/tailscale:latest";
        environment = {
          TS_STATE_DIR = "/var/lib/tailscale";
          TS_SERVE_CONFIG = "/config/serve.json";
          TS_USERSPACE = "false";
        };
        environmentFiles = [
          config.age.secrets."tailscale-share-env".path
        ];
        volumes = [
          "/var/lib/tailscale-immich-share:/var/lib/tailscale"
          "${tailscaleServeConfig}:/config/serve.json:ro"
          "/run/tailscale-immich-share/resolv.conf:/etc/resolv.conf:ro"
          "/dev/net/tun:/dev/net/tun"
        ];
        extraOptions = [
          "--cap-add=NET_ADMIN"
          "--cap-add=SYS_MODULE"
          "--hostname=${shareCfg.tailscaleHostname}"
        ];
      };

      immich-public-proxy = {
        image = "ghcr.io/alangrainger/immich-public-proxy:latest";
        environment = {
          IMMICH_URL = "http://172.17.0.1:${toString config.services.immich.port}";
        } // lib.optionalAttrs (fqdn != null) {
          PUBLIC_BASE_URL = "https://${fqdn}";
        };
        environmentFiles = [
          config.age.secrets."tailscale-share-env".path
        ];
        dependsOn = [ "tailscale-immich-share" ];
        extraOptions = [
          "--network=container:tailscale-immich-share"
        ];
      };
    };

    systemd.services."docker-tailscale-immich-share" = lib.mkIf shareCfg.enable {
      preStart = ''
        mkdir -p /run/tailscale-immich-share
        RESOLV_CONF="/run/tailscale-immich-share/resolv.conf"
        > "$RESOLV_CONF"

        ${lib.optionalString (shareCfg.dns != [ ]) ''
          ${lib.concatMapStringsSep "\n" (ip: "echo 'nameserver ${ip}' >> \"$RESOLV_CONF\"") shareCfg.dns}
        ''}
        ${lib.optionalString (shareCfg.dns == [ ]) ''
          DNS_IP=""
          if [ -f "${config.age.secrets."tailscale-share-env".path}" ]; then
            DNS_IP=$(${pkgs.gnugrep}/bin/grep -E '^UPSTREAM_DNS=' "${config.age.secrets."tailscale-share-env".path}" | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' "' || true)
          fi
          if [ -z "$DNS_IP" ] && [ -x "${pkgs.networkmanager}/bin/nmcli" ]; then
            DNS_IP=$(${pkgs.networkmanager}/bin/nmcli -g IP4.DNS dev show 2>/dev/null | ${pkgs.gnugrep}/bin/grep -v '^$' | ${pkgs.coreutils}/bin/head -n 1 || true)
          fi
          if [ -n "$DNS_IP" ]; then
            echo "nameserver $DNS_IP" >> "$RESOLV_CONF"
          fi
          if [ "$DNS_IP" != "1.1.1.1" ]; then
            echo "nameserver 1.1.1.1" >> "$RESOLV_CONF"
          fi
        ''}
      '';
    };

    systemd.services."docker-immich-public-proxy" = lib.mkIf shareCfg.enable {
      after = [ "docker-tailscale-immich-share.service" ];
      requires = [ "docker-tailscale-immich-share.service" ];
    };
  };
}
