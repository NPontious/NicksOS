{ config, ... }:

let
  dataDir = "/mnt/data/backups/restic";
in
{
  # Monthly integrity check of /mnt/data.
  services.btrfs.autoScrub.enable = true;

  # Receives glacio's nightly restic backups. Append-only: a compromised client
  # can add snapshots but not delete or overwrite them, so pruning runs here.
  # Port 8000 isn't opened in the firewall, so it's only reachable over tailscale.
  services.restic.server = {
    enable = true;
    inherit dataDir;
    appendOnly = true;
    privateRepos = true;
    htpasswd-file = config.age.secrets."restic-server-htpasswd".path;
  };

  # Weekly retention + a partial integrity check of glacio's repository.
  services.restic.backups.prune-glacio = {
    repository = "${dataDir}/glacio";
    passwordFile = config.age.secrets."restic-password".path;
    user = "restic";
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 5"
      "--keep-monthly 12"
    ];
    checkOpts = [ "--read-data-subset=5%" ];
    timerConfig = {
      OnCalendar = "Sun 06:00";
      Persistent = true;
    };
  };

  # /mnt/data is nofail; never write backups into the bare mountpoint.
  systemd.services.restic-rest-server.unitConfig.RequiresMountsFor = [ dataDir ];
  systemd.services.restic-backups-prune-glacio.unitConfig.RequiresMountsFor = [ dataDir ];

  age.secrets = {
    "restic-server-htpasswd" = {
      file = ../../secrets/restic-server-htpasswd.age;
      mode = "0400";
      owner = "restic";
    };
    "restic-password" = {
      file = ../../secrets/restic-password.age;
      mode = "0400";
      owner = "restic";
    };
  };
}
