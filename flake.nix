{
  description = "Containerized Backend for the FlashDeck";

  outputs = { self, nixpkgs }: {
    nixosModules.default = { config, pkgs, lib, ... }:
    let
      cfg = config.services.flashdeck;

      backends = [
        { name = "user-defined";  value = cfg.backend;  cond = cfg.backend != null; }
        { name = "docker";        value = "docker";     cond = config.virtualisation.docker.enable; }
        { name = "podman";        value = "podman";     cond = config.virtualisation.podman.enable; }
      ];

      effectiveBackend = (lib.findFirst (x: x.cond) { name = "none"; value = "none"; } backends).value;

      backendData = with pkgs; {
        docker = {
          bin = "${docker-compose}/bin/docker-compose";
          deps = [ "docker.service" ];
          packages = [ docker docker-compose ];
        };
        podman = {
          bin = "${podman-compose}/bin/podman-compose";
          deps = [ "podman.socket" ];
          packages = [ podman podman-compose ];
        };
        none = { bin = ""; deps = []; packages = []; };
      }.${effectiveBackend};

    in {
      options.services.flashdeck = {
        enable = lib.mkEnableOption "FlashDeck backend service";

        backend = lib.mkOption {
          type = lib.types.nullOr (lib.types.enum [ "docker" "podman" ]);
          default = null;
          description = "Backend to use";
        };

        envVariables = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
          description = "Env variables for the `.env`";
        };
      };

      config = lib.mkIf cfg.enable {
        assertions = [{
          assertion = effectiveBackend != "none";
          message = ''
            FlashDeck error: No container backend detected!
            Please enable docker (virtualisation.docker.enable = true)
            or podman (virtualisation.podman.enable = true),
            or set services.flashdeck.backend explicitly.
          '';
        }];

        systemd.services.flashdeck-backend = {
          description = "FlashDeck Backend Containers (${effectiveBackend})";

          after = [ "network-online.target" ] ++ backendData.deps;
          requires = backendData.deps;
          wantedBy = [ "multi-user.target" ];

          path = with pkgs; [ coreutils ] ++ backendData.packages;

          environment = cfg.envVariables;

          script = ''
            set -e
            cd ${self.outPath}
            echo "Starting FlashDeck via ${effectiveBackend} from Nix Store..."
            ${backendData.bin} up -d
          '';

          preStop = ''
            cd ${self.outPath}
            ${backendData.bin} down
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            StateDirectory = "flash-deck";
            WorkingDirectory = "/var/lib/flash-deck";
          };
        };
      };
    };
  };
}
