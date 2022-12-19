{
  inputs.nixpkgs.url = "nixpkgs/release-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";

  inputs.nil.url = "github:oxalica/nil?ref=2022-12-01"; 

  outputs = { self, nil, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ inputs.rust-overlay.overlays.default ];

        pkgs = import inputs.nixpkgs { inherit system overlays; };

        callPackage = pkgs.lib.callPackageWith {inherit pkgs;};

        rust = callPackage ./rust { inherit (inputs) crane rust-overlay; };

        checks = callPackage ./checks {inherit rust;} ;
      in
      {
        inherit rust;
        inherit (checks) checks;

        apps.check-scripts = {
          "type" = "app";
          "program" = "${checks.scripts.check-builds-failing}/bin/check-builds-failing";
        };

        testPackages = checks.testPackages;

        devShells.default = pkgs.mkShell {
          buildInputs = [ 
            pkgs.nixpkgs-fmt
            # nil.packages.${system}.default
          ];
        };
      }
    );
}
