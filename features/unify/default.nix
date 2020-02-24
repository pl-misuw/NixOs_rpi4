{ config, pkgs, lib, ... }:

{
  systemd.services.unifi-controller = {
    description = "unifi-controller";
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    requires = [ "docker.service" "docker.socket" ];
    script = ''
      exec ${pkgs.docker}/bin/docker run \
          --rm \
          --name=unifi-controller \
          --network=host \
          -e PUID=1000 \
          -e PGID=1000 \
          -e MEM_LIMIT=512M\
          -v /home/plmisuw/share/unify_config:/config \
          linuxserver/unifi-controller:arm64v8-5.12.35-ls49
    '';
    preStop = "${pkgs.docker}/bin/docker stop unifi-controller";
    reload = "${pkgs.docker}/bin/docker restart unifi-controller";
    serviceConfig = {
      ExecStartPre = "-${pkgs.docker}/bin/docker rm -f unifi-controller";
      ExecStopPost = "-${pkgs.docker}/bin/docker rm -f unifi-controller";
      TimeoutStartSec = 0;
      TimeoutStopSec = 120;
      Restart = "unless-stopped";
    };
  };
}