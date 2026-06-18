{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            nodejs_22
            direnv
          ];

          shellHook = ''
            eval "$(direnv hook bash)"
            direnv allow
          '';
        };

        packages = {
          recording-monitor = pkgs.buildNpmPackage {
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

          default = self.packages.${system}.recording-monitor;
        };

        darwinModules.default =
          { config, lib, ... }:
          let
            cfg = config.services.recording-monitor;
          in
          {
            options.services.recording-monitor = {
              enable = lib.mkEnableOption "Recording Monitor";
              configFile = lib.mkOption {
                type = lib.types.str;
                description = "Location of the configuration file";
              };
            };

            config = lib.mkIf cfg.enable {
              launchd.user.agents.recording-monitor = {
                serviceConfig = {
                  ProgramArguments = [
                    "${self.packages.${system}.default}/bin/recording-monitor"
                  ];

                  EnvironmentVariables = {
                    CONFIG_FILE = cfg.configFile;
                  };

                  RunAtLoad = true;
                  KeepAlive = true;
                };
              };
            };
          };
      }
    );
}
