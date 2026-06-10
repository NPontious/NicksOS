{ config, lib, pkgs, ... }:

{
  options.mySystem.hardware.intel.enable = lib.mkEnableOption "Intel Graphics Support";

  config = lib.mkIf config.mySystem.hardware.intel.enable {
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        libvdpau-va-gl
      ];
    };

    environment.systemPackages = with pkgs; [
      intel-gpu-tools
    ];

    boot.kernel.sysctl = {
      "kernel.perf_event_paranoid" = 0;
      "dev.i915.perf_stream_paranoid" = 0;
    };

    nixpkgs.overlays = [
      (final: prev: {
        btop = prev.btop.overrideAttrs (oldAttrs: {
          buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ final.libdrm ];
        });
      })
    ];
  };
}
