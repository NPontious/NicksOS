{ config, lib, pkgs, ... }:

let
  sylvaHostPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBn2c/9xEqfTocaT2HfIAjEKYgJytv/dUq5Kr9TDdhCv";
  sylvaPublicHostKeyBase64 = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUJuMmMvOXhFcWZUb2NhVDJIZklBakVLWWdKeXR2L2RVcTVLcjlURGRoQ3Ygcm9vdEBzeWx2YQo=";

  clientHostKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDASAHScag9TBoXy0oZKTR67BykcH5g5HTrqLsbABLnl root@glacio"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOQmu30vMqi1V8v8iUk3/EF6r8+l+ujSruqq+At7j3oj root@vesania"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINhXX59EL8xxxnMQkaPYD+J1s70JXiAPFqBlPSNsFYDJ root@nixos"
  ];
in
{
  options.mySystem = {
    buildServer.enable = lib.mkEnableOption "Nix build server configuration (builds for other nodes)";
    distributedBuilds.enable = lib.mkEnableOption "Nix distributed builds client (offloads builds to sylva)";
  };

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(config.mySystem.buildServer.enable && config.mySystem.distributedBuilds.enable);
          message = "Host '${config.networking.hostName}' cannot have both mySystem.buildServer and mySystem.distributedBuilds enabled.";
        }
      ];
    }

    (lib.mkIf config.mySystem.buildServer.enable {
      nix.settings = {
        trusted-users = [ "root" "@wheel" config.mySystem.mainUser ];
      };

      users.users.root.openssh.authorizedKeys.keys = clientHostKeys;

      services.openssh.settings.PermitRootLogin = "prohibit-password";

      environment.shellAliases = {
        deploy-glacio = "nixos-rebuild switch --flake '/etc/nixos#glacio' --target-host nicho@glacio --use-remote-sudo";
        deploy-vesania = "nixos-rebuild switch --flake '/etc/nixos#vesania' --target-host nicho@vesania --use-remote-sudo";
        deploy-desolo = "nixos-rebuild switch --flake '/etc/nixos#desolo' --target-host nicho@desolo --use-remote-sudo";
      };
    })

    (lib.mkIf config.mySystem.distributedBuilds.enable {
      nix = {
        distributedBuilds = true;
        buildMachines = [
          {
            hostName = "sylva";
            systems = [ "x86_64-linux" ];
            protocol = "ssh-ng";
            maxJobs = 16;
            speedFactor = 2;
            supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
            mandatoryFeatures = [ ];
            sshUser = "root";
            sshKey = "/etc/ssh/ssh_host_ed25519_key";
            publicHostKey = sylvaPublicHostKeyBase64;
          }
        ];
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };

      programs.ssh.knownHosts = {
        sylva = {
          hostNames = [ "sylva" ];
          publicKey = sylvaHostPublicKey;
        };
      };
    })
  ];
}
