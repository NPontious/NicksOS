{ config, pkgs, lib, ... }:

{
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Broadwell (2014) or newer
      intel-vaapi-driver # For older
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
}
