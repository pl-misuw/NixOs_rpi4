{ config, pkgs, lib, ... }:

{
  # Enable cron service
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/5 * * * *      root    date >> /tmp/cron.log"
      "@hourly  root  speedtest-cli --csv --csv-delimiter ',' >> /home/plmisuw/share/netspeed.csv"
    ];
  };

  #services.kubernetes.kubelet.extraOpts = "--fail-swap-on=false";
  #systemd.services.flannel.environment = "10.0.0.0/8";
    
  #nixpkgs.config.allowUnsupportedSystem = true;  
  environment.systemPackages = with pkgs; [
    #Sys tools
    mkpasswd
    zsh
    fzf
    wget
    speedtest-cli

    # Dev tools
    git
    nix-prefetch-scripts
    vim

    #Cluster tools
    #podman
    skopeo
    docker
    docker-compose
    kubectl  

    # Utilities
    tree
    findutils
    htop
    dnsutils
    openssl
  ];

  # Make instantiate persistent nix-shell possible.
  nix.extraOptions = "keep-outputs = true";

  environment.interactiveShellInit = ''
    export EDITOR=vi
    alias df='df -hT'
    alias du='du -hs'
    alias ll='ls -lah'
  '';

  # Don't install NixOS manual
  #documentation.nixos.enable = false;

  system.stateVersion = "20.03";
}