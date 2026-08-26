{ config, pkgs, illogical-flake, lib, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../common.nix
    ../../modules/tailscale.nix
    ../../modules/illogical.nix
    ../../modules/intel.nix
  ];

  networking.hostName = "desolo";

  services.hardware.bolt.enable = true;
  boot.initrd.availableKernelModules = [ "thunderbolt" "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "i915" ];

  mySystem.illogical.enableShell = true;
  mySystem.illogical.enableDesktop = false;

  myAppSets.profile = "server";

  mySystem.tailscale.enable = true;
  mySystem.hardware.intel.enable = true;

  system.stateVersion = "25.11"; 

  fileSystems."/mnt/data" = {
    device = "/dev/disk/by-uuid/93f7f05e-4fb7-440c-9bd8-824a23d12f45";
    fsType = "btrfs";
    options = [ "defaults" "nofail" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /mnt/data 192.168.100.0/24(rw,sync,no_subtree_check,no_root_squash)
  '';
  
  # firewall port for NFSv4
  networking.firewall.allowedTCPPorts = [ 2049 ];

  users.users.isa = {
    isNormalUser = true;
    description = "Wife's account";
    extraGroups = [ config.mySystem.mediaGroup ];
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "desolo smb";
        "security" = "user";
      };
      "data" = {
        "path" = "/mnt/data";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = "nicho, isa";
        "hide unreadable" = "yes";
        "force group" = config.mySystem.mediaGroup;
        "create mask" = "0660";
        "directory mask" = "2770";
      };
    };
  };
}
