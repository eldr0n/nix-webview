{
  description = "A Nix library to create webview webapps using pywebview";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      # System-independent lib
      baseLib = {
        makeWebviewApp = import ./pkgs/webview-webapp;
      };
      
      eachSystemOutputs = flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Convenient helper for this system
          makeWebviewApp = baseLib.makeWebviewApp { inherit pkgs; lib = pkgs.lib; };
        in
        {
          # System-dependent helper
          lib = { inherit makeWebviewApp; };

          packages = {
            # Example webapp
            google = makeWebviewApp {
              name = "google";
              url = "https://www.google.com";
              width = 1200;
              height = 800;
              iconHash = "sha256-baViCIAVljQhPhl/r8od3gJyFTvj5FkIGFM/q40EB3A=";
            };
            default = self.packages.${system}.google;
          };
        }
      );
    in
    eachSystemOutputs // {
      # Top-level lib if someone wants to pass their own pkgs
      lib = eachSystemOutputs.lib // baseLib;

      # Home Manager module
      homeManagerModules.default = import ./modules/home-manager;
      homeManagerModule = self.homeManagerModules.default;
    };
}
