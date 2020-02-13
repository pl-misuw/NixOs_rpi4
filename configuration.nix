{ config, pkgs, lib, ... }:

let
  # Use latest main line kernel
  #kernel = pkgs.linuxPackages_latest;
  # Use latest lts kernel
  #kernel = pkgs.linuxPackages;
  # Use Linux kernel for rpi4
  kernel = pkgs.linuxPackages_rpi4;
in

{
  #####################
  # nix global config #
  #####################

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
    "nixpkgs-overlays=/etc/nixos/overlays"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
  ];

  imports = [
    # Extra modules
    ./modules

    # Program config
    ./programs/zsh
    ./programs/tmux
  ];

  environment.systemPackages = with pkgs; [
    # GNU userland
    coreutils
    gnumake
    gnugrep
    gnused

    # System config
    mkpasswd

    # Dev tools
    git
    tig
    fzf
    ripgrep
    cmake
    ctags
    nix-prefetch-scripts

    # Utilities
    tree
    findutils
    pstree
    htop
  ];

  # Make instantiate persistent nix-shell possible.
  nix.extraOptions = "keep-outputs = true";

  environment.interactiveShellInit = ''
    export EDITOR=vi
    alias df='df -hT'
    alias du='du -hs'
    alias nix-shell='nix-shell --run zsh'
    alias nix-reg='nix-instantiate shell.nix --indirect --add-root $HOME/.gcroots/$(basename $(pwd))'
    alias nix-sys-installed='nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq'
    alias nix-sys-generations='sudo nix-env --list-generations --profile /nix/var/nix/profiles/system'
  '';

  # Don't install NixOS manual
  #documentation.nixos.enable = false;

  system.stateVersion = "20.03";


  #################################
  # NixOS config for Raspberry Pi #
  #################################

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  #boot.loader.generic-extlinux-compatible.enable = true;

  # rpi foundation's bootloader settings
  boot.loader.raspberryPi = {
    enable = true;
    version = 4;
    #uboot.enable = true;

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
  hardware.deviceTree = {
    overlays = [{
      overlay = "${kernel.kernel}/dtbs/overlays/w1-gpio-pullup.dtbo";
    }];
  };

  # udev rules for burn-in software debugging
  services.udev.packages = with pkgs; [
    usb-relay-udev-rules
    gpiomem-udev-rules
  ];


  ########################
  # Host-specific config #
  ########################

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "NixBerry";
  networking.wireless.enable = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall.enable = false;

  time.timeZone = "Europe/Warsaw";

  # SSH configuration
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # sudo configuration
  security.sudo.wheelNeedsPassword = false;


  ###################
  # User management #
  ###################

  # Fully control all user settings declaratively
  # i.e. "passwd" command will be non-effective
  users.mutableUsers = false;

  # Extra groups
  users.groups.gpio = {};

  users.users.root = {
    shell = pkgs.zsh;
    hashedPassword = "$5$95d04woG0fZuzx$xAi.yYeEcM1qRomxXRIEv/44o.PwfrF9xu8BDjjNMx4";
  };

  users.users.plmisuw = {
    isNormalUser = true;
    home = "/home/plmisuw";
    description = "UMD plmisuw group user";
    extraGroups = [ "wheel" "gpio" ];
    shell = pkgs.zsh;
    hashedPassword = "$5$95d04woG0fZuzx$xAi.yYeEcM1qRomxXRIEv/44o.PwfrF9xu8BDjjNMx4";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmWtgHVDhLNJxTwmzU2YMY0kiYJCTxZBMLVs2qtIg728wiOkH4RO6+SGEx7eMhW5w1TzXauokjdnGApT5EnHUto284Pa/o5MRuWkn0hzAwLv9SLZ7fu1DpEY9NjAHVgGSh+eR0Wz6sKCVs+0NJd0gLp2han5yZ62H6L0dYk7iJxJwZYBwfhfaCHCz77f7hOsWwhlLx3Ob8On/xFxtq4zjb+vUMwdfEjR2Aks3QjoEC/F1PrkirSwNgPdoh2ZRamBNFE81RpbOrmECB0q+N/s4qbdiV0LDDm7yJNtp6O4VmPFKzo9M9bWKQ9VrE4ugIpd28qUO/RxLmsxKZCYdiSuod admin@THE_MACHINE"
    ];
  };
}