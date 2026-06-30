{ config, pkgs, ... }:

{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    mode = "boot";
    # Pointing to the files built in step 1
    kernel = "/tmp/netboot-result/bzImage";
    initrd = "/tmp/netboot-result/initrd";
    # Optional: If you have another DHCP server (like a router), 
    # pixiecore will only handle the PXE portion.
    dhcpNoBind = true; 
  };
}
