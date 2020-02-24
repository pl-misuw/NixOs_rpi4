{ config, pkgs, lib, ... }:

{
  # Enable k8s service
  services.kubernetes = {
    roles = [ "master" "node" ];
    masterAddress = "k8s.suvarhalla";
    easyCerts = true;
    kubelet.extraOpts = "--fail-swap-on=false";
    addons.dashboard.enable = true;
  };
  systemd.services.etcd.environment.ETCD_UNSUPPORTED_ARCH = "arm64";  
}