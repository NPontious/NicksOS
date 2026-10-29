{ config, pkgs, ... }:

let
  docker = "${config.virtualisation.docker.package}/bin/docker";
  containerDumps = "/var/backup/containers";
in
{
  # Monthly integrity check of /mnt/storage.
  services.btrfs.autoScrub.enable = true;

  # Hourly local snapshots of /mnt/storage: an undo button for deletions, not a
  # backup (same disk). Keeps everything for 2 days, then dailies for 14 days
  # and weeklies for 8 weeks.
  services.btrbk.instances.storage = {
    onCalendar = "hourly";
    settings = {
      snapshot_preserve_min = "2d";
      snapshot_preserve = "14d 8w";
      subvolume."/mnt/storage".snapshot_dir = "/mnt/storage/.snapshots";
    };
  };

  # Nightly (01:15) dump of the host PostgreSQL (immich) into /var/backup.
  services.postgresqlBackup = {
    enable = true;
    compression = "none"; # restic compresses and dedups plain dumps better
  };

  # Nightly restic backup to desolo's append-only REST server, over tailscale.
  # Pruning runs on desolo, since this client can't delete from the repo.
  services.restic.backups.desolo = {
    repositoryFile = config.age.secrets."restic-glacio-repository".path;
    passwordFile = config.age.secrets."restic-password".path;
    initialize = true;
    paths = [
      "/mnt/storage"
      "/var/backup"
      "/var/lib/nixos" # uid/gid allocations
      "/var/lib/hass"
      "/var/lib/sonarr"
      "/var/lib/radarr"
      "/var/lib/lidarr"
      "/var/lib/private/prowlarr"
      "/var/lib/jellyfin"
      "/var/lib/tandoor-recipes"
      "/var/lib/private/open-webui"
      "/var/lib/inkypi"
      "/var/lib/qbittorrent"
      "/var/lib/medialyze"
      "/var/lib/docker/volumes/sure_app-storage"
      "/var/lib/docker/volumes/penpot_penpot_assets"
      "/var/lib/docker/volumes/freellmapi_freellmapi-data"
    ];
    exclude = [
      "/mnt/storage/.snapshots"
      "/mnt/storage/Git" # Forgejo is itself a mirror of GitHub
      "/var/lib/qbittorrent/Downloads"
      "/var/lib/jellyfin/transcodes"
    ];
    # Consistent dumps of the containerised databases. A failed dump keeps the
    # previous one rather than failing the whole backup.
    backupPrepareCommand = ''
      umask 077
      mkdir -p ${containerDumps}
      dump() {
        if ${docker} exec "$1" pg_dumpall -U "$2" > "${containerDumps}/$1.sql.tmp"; then
          mv "${containerDumps}/$1.sql.tmp" "${containerDumps}/$1.sql"
        else
          rm -f "${containerDumps}/$1.sql.tmp"
          echo "warning: could not dump $1, keeping the previous dump" >&2
        fi
      }
      dump sure-db sure_user
      dump penpot-penpot-postgres penpot
    '';
    timerConfig = {
      OnCalendar = "03:30";
      Persistent = true;
      RandomizedDelaySec = "15m";
    };
  };

  # /mnt/storage is an automount with nofail; don't snapshot or back up an empty mountpoint.
  systemd.services.restic-backups-desolo.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];
  systemd.services.btrbk-storage.unitConfig.RequiresMountsFor = [ "/mnt/storage" ];

  systemd.tmpfiles.rules = [
    "d /mnt/storage/.snapshots 0755 root root -"
  ];

  age.secrets = {
    "restic-glacio-repository" = {
      file = ../../secrets/restic-glacio-repository.age;
      mode = "0400";
    };
    "restic-password" = {
      file = ../../secrets/restic-password.age;
      mode = "0400";
    };
  };
}
