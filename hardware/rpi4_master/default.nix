{ config, pkgs, lib, ... }:

{
  ########################
  # Host-specific config #
  ########################

  i18n.defaultLocale = "en_US.UTF-8";
  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.hostName = "k8s.suvarhalla";
  networking.wireless.enable = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 8080 8081 8443 8843 8880 6789];
    allowedUDPPorts = [ 3478 10001 51820 ];
    allowPing = true;
    extraCommands = ''
    iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';
  }

  time.timeZone = "Europe/Warsaw";

  # SSH configuration
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # sudo configuration
  security.sudo.wheelNeedsPassword = false;

  ####################
  #  Virtualisation  #
  ####################

  virtualisation.docker.enable = true;

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
    group = "users";
    description = "plmisuw group user";
    extraGroups = [ "wheel" "gpio" "networkmanager" "docker" ];
    shell = pkgs.zsh;
    hashedPassword = "$5$95d04woG0fZuzx$xAi.yYeEcM1qRomxXRIEv/44o.PwfrF9xu8BDjjNMx4";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmWtgHVDhLNJxTwmzU2YMY0kiYJCTxZBMLVs2qtIg728wiOkH4RO6+SGEx7eMhW5w1TzXauokjdnGApT5EnHUto284Pa/o5MRuWkn0hzAwLv9SLZ7fu1DpEY9NjAHVgGSh+eR0Wz6sKCVs+0NJd0gLp2han5yZ62H6L0dYk7iJxJwZYBwfhfaCHCz77f7hOsWwhlLx3Ob8On/xFxtq4zjb+vUMwdfEjR2Aks3QjoEC/F1PrkirSwNgPdoh2ZRamBNFE81RpbOrmECB0q+N/s4qbdiV0LDDm7yJNtp6O4VmPFKzo9M9bWKQ9VrE4ugIpd28qUO/RxLmsxKZCYdiSuod admin@THE_MACHINE"
    ];
  };
}
