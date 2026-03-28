{ config, pkgs, ... }:

{
  imports = [
    ./pkg-sets.nix
  ];

  home.stateVersion = "24.05";
}
