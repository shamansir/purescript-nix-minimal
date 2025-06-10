{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    ps-overlay.url = "github:thomashoneyman/purescript-overlay";
    mkSpagoDerivation = { 
      url = "github:jeslie0/mkSpagoDerivation";
      inputs = {
        registry.url = "github:purescript/registry/fe3f499706755bb8a501bf989ed0f592295bb4e3";
        registry-index.url = "github:purescript/registry-index/a349ca528812c89915ccc98cfbd97c9731aa5d0b";
      };
    };
  };

  outputs = { self, nixpkgs, flake-utils, ps-overlay, mkSpagoDerivation }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ mkSpagoDerivation.overlays.default
                       ps-overlay.overlays.default
                     ];
        };
    
      
        myPackage =
            pkgs.mkSpagoDerivation {
              spagoYaml = ./spago.yaml;
              spagoLock = ./spago.lock;
              src = ./.;
              version = "0.1.0";
              nativeBuildInputs = [ pkgs.esbuild pkgs.purs-backend-es pkgs.purs-unstable pkgs.spago-unstable ];
              buildPhase = "spago build --output ./output-es && purs-backend-es bundle-app --no-build --minify --to=main.min.js";
              installPhase = "mkdir $out; cp -r main.min.js $out";
              buildNodeModulesArgs = {
                npmRoot = ./.;
                nodejs = pkgs.nodejs;
              };
            };

        myScript = pkgs.runCommand "my-script" {} ''
            mkdir -p $out
            cat > $out/script <<EOF
            #!/bin/sh
            exec ${pkgs.nodejs}/bin/node ${myPackage}/main.min.js "\$@"
            EOF
            chmod +x $out/script 
          '';


      in     
        {
          packages.default = myPackage;

          # output1 = { 
          #  type = "app";
          #  program = toString (pkgs.writeScriptBin "myscript" ''
            #    echo "foo"
            #  '');
            # };
        #
          
          apps.output1 = { 
              type = "app";
              program = "${myScript}/script";
            # program = pkgs.writeScriptBin "myscript" ''
            #    echo "foo"
            #  '';
          };

        }

    );
}
