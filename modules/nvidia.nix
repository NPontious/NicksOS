{ config, lib, pkgs, ... }:

{
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA Graphics Support";

  config = lib.mkIf config.mySystem.hardware.nvidia.enable {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["nvidia"];

    hardware.nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    nixpkgs.overlays = [
      (final: prev: {
        btop = prev.btop.override { cudaSupport = true; };
      })
    ];
  };
}
