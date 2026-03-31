{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/secrets.nix
  ];

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages; 

  networking.networkmanager.enable = true;

  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;
  users.users.nicho = {
    isNormalUser = true;
    description = "nicho";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "render" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [ 
    kitty tree git net-tools wget curl btop
  ];
}
