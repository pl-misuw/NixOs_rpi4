{ config, pkgs, lib, ... }:

let
  # Kernel for rpi4
  kernel = pkgs.linuxPackages_rpi4;
in

{
  #####################
  # nix global config #
  #####################

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    ./features/k8s 
    ./features/unify 
    ./features/zsh 
    ./hardware/rpi4_master
    ./profiles/pl-misuw
  ];

  #################################
  # NixOS config for Raspberry Pi #
  #################################

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;

  # rpi foundation's bootloader settings
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;

    firmwareConfig = ''
      dtoverlay=w1-gpio-pullup
    '';
  };

  boot.kernelPackages = kernel;

  boot.initrd.availableKernelModules = [
    "usbhid"
    "vc4"
    "bcm2835_dma"
    "i2c_bcm2835"
  ];

  # Needed for the virtual console to work on the RPi 3, as the default of 16M
  # doesn't seem to be enough.  If X.org behaves weirdly (I only saw the
  # cursor) then try increasing this to 256M.  On a Raspberry Pi 4 with 4 GB,
  # you should either disable this parameter or increase to at least 64M if you
  # want the USB ports to work.
  boot.kernelParams = [
    "cma=64M"  # rpi4 default
    "console=ttyS0,115200n8"
    "console=ttyAMA0,115200n8"
    "console=tty0"
  ];

  #boot.extraModulePackages = with pkgs; [
    #linuxPackages_rpi4.w1-gpio-cl
  #];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };

  # Swap device. It's needed!
  swapDevices = [{
    device = "/swapfile";
    size = 4096;
  }];

  # Hardware settings
  hardware.bluetooth.enable = false;
  hardware.enableRedistributableFirmware = true;
}