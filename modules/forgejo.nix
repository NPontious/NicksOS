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
        
        # Enable Forgejo Actions (CI/CD)
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
        
        # Enable the built-in Container Registry and other package types
        packages = {
          ENABLED = true;
        };
      };
    };

    # Set up the Forgejo Runner for executing your workflows
    services.gitea-actions-runner = {
      package = pkgs.forgejo-runner;
      instances.glacio-runner = {
        enable = true;
        name = "glacio-runner";
        # Connect to the local Forgejo instance
        url = "http://127.0.0.1:3030/";
        
        # Save the GLOBAL registration token into this file
        tokenFile = "/etc/forgejo-runner-token";
        
        # Specify what environments this runner can provide
        labels = [
          "ubuntu-latest:docker://node:22-bookworm"
          "native:host"
        ];
      };
    };

    # The runner needs a container backend to run 'ubuntu-latest' jobs
    virtualisation.docker.enable = true;

    # Ensure the storage directory exists and has the correct permissions
    # for the Forgejo service user to read and write.
    systemd.tmpfiles.rules = [
      "d /mnt/storage/Git 0750 forgejo forgejo - -"
    ];
  };
}
