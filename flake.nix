{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "aarch64-darwin";

      pkgs = import nixpkgs { inherit system; };
    in
    {
      # ---------------------------
      # PACKAGE
      # ---------------------------
      packages.${system}.default = pkgs.buildNpmPackage {
        pname = "recording-monitor";
        version = "1.0.0";

        src = ./.;

        npmDepsHash = "sha256-9BA8yQ22rM6Be13iu/FqPQQ8oGUbDBzp6VBrHOXhPNo=";
        dontNpmBuild = true;

        installPhase = ''
          runHook preInstall

          mkdir -p $out/bin

          cat > $out/bin/recording-monitor <<EOF
          #!${pkgs.bash}/bin/bash
          exec ${pkgs.nodejs}/bin/node $out/app/src/index.js
          EOF

          chmod +x $out/bin/recording-monitor

          mkdir -p $out/app
          cp -R src package.json node_modules $out/app

          runHook postInstall
        '';
      };

      # ---------------------------
      # DARWIN MODULE
      # ---------------------------
      darwinModules.recording-monitor =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.services.recording-monitor;
        in
        {
          options.services.recording-monitor = {
            enable = lib.mkEnableOption "Recording Monitor";

            configFile = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = "Path to config file";
            };

            package = lib.mkOption {
              type = lib.types.package;
              default = self.packages.${system}.default;
              description = "Package to run";
            };
          };

          config = lib.mkIf cfg.enable {
            launchd.user.agents.recording-monitor = {
              serviceConfig = {
                ProgramArguments = [
                  "${cfg.package}/bin/recording-monitor"
                ];

                EnvironmentVariables = {
                  RECORDING_MONITOR_CONFIG_FILE = cfg.configFile;
                };

                RunAtLoad = true;
                KeepAlive = true;
              };
            };
          };
        };

      # ---------------------------
      # DEV SHELL
      # ---------------------------
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_22
          direnv
        ];

        shellHook = ''
          eval "$(direnv hook bash)"
        '';
      };
    };
}
