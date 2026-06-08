{ config, pkgs, ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      show_gpu_info = "On";
      shown_gpus = "nvidia amd intel apple";
    };
  };

  home.stateVersion = "24.05";
}
