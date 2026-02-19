{
  description = "Containerized Backend for the FlashDeck";

  outputs = {
    self,
    nixpkgs,
  }: {
    nixosModules.default = {
      config,
      pkgs,
      lib,
      ...
    }: let
      cfg = config.services.flashdeck;
    in {
      options.services.flashdeck = {
        enable = lib.mkEnableOption "FlashDeck backend service";

        envVariables = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
          description = "Env variables for the `.env`";
          example = {
            PGRST_JWT_SECRET = "my-secret";
          };
        };
      };

      config = lib.mkIf cfg.enable {
        virtualisation.podman = {
          enable = true;
          dockerCompat = true;
        };

        systemd.services.flashdeck-backend = {
          description = "FlashDeck Backend (Pure Nix)";
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          path = [pkgs.podman pkgs.podman-compose pkgs.coreutils];

          environment = cfg.envVariables;

          script = ''
            cd ${self.outPath}
            podman-compose up -d
          '';

          preStop = ''
            cd ${self.outPath}
            podman-compose down
          '';

          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            WorkingDirectory = "/var/lib/flash-deck";
            StateDirectory = "flash-deck";
          };
        };
      };
    };
  };
}
