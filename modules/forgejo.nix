{ config, lib, pkgs, ... }:

{
  options.mySystem.services.forgejo.enable = lib.mkEnableOption "Forgejo Git Service";

  config = lib.mkIf config.mySystem.services.forgejo.enable {
    services.forgejo = {
      enable = true;
      
      # Set the storage location for Git repositories.
      repositoryRoot = "/mnt/storage/Git/";

      settings = {
        server = {
          HTTP_PORT = 3030;
        };
        
        # Mirroring settings
        mirror = {
          # By default, push mirrors are enabled, but we make sure they are not disabled.
          DISABLE_NEW_PUSH = false;
        };
        
        repository = {
          # You can optionally limit the number of push mirrors in the queue. 
          # Uncomment and adjust if needed:
          # PUSH_LIMIT = 50; 
        };
      };
    };

    # Ensure the storage directory exists and has the correct permissions
    # for the Forgejo service user to read and write.
    systemd.tmpfiles.rules = [
      "d /mnt/storage/Git 0750 forgejo forgejo - -"
    ];
  };
}
