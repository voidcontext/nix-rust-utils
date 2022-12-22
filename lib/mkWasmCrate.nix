{pkgs, callPackage, attrFromCargoToml, ...}:

let
	mkCrate = callPackage ./mkCrate.nix {};
	defaultToolchain = pkgs.rust-bin.stable."1.61.0".default.override {
		targets = ["wasm32-unknown-unknown"];
	};
	testRunnerConfigured = src:
		with pkgs.lib;
		with builtins;
		let cargoConfig =  src + "/.cargo/config";
		in
			sources.pathIsRegularFile ( src + "/.cargo/config") && 
				(attrsets.hasAttrByPath 
					["target" "wasm32-unknown-unknown" "runner"] 
					(fromTOML (readFile cargoConfig)))
	;
in
{ src
, pname ? attrFromCargoToml src [ "package" "name" ]
, version ? attrFromCargoToml src [ "package" "version" ]
, rustToolchain ? defaultToolchain 
, doCheck ? true
}: # TODO: passthrough all arguments
let
	binaryName = builtins.replaceStrings ["-"] ["_"] pname;
in
	assert pkgs.lib.asserts.assertMsg (!doCheck || (testRunnerConfigured src)) "doCheck must be false or a test runner must be configured";
	mkCrate {
		inherit src pname version rustToolchain doCheck;
		
		cargoExtraArgs = "--target=wasm32-unknown-unknown";
		
		buildInputs = [
      pkgs.binaryen
      pkgs.wasm-bindgen-cli
		];

		packagePostBuild = ''
      wasm-bindgen                                                          \
        --target web                                                        \
        --out-dir dist                                                      \
        --no-typescript                                                     \
        target/wasm32-unknown-unknown/release/${binaryName}.wasm
		'';

		# TODO: postInstall -> copy js files over too
	}