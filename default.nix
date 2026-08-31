{
  system ? builtins.currentSystem,
  sources ? import ./sources.nix,
  rust-overlay ? sources.rust-overlay,
  pkgs ? import sources.nixpkgs {
    inherit system;
  },
  crane ? import sources.crane { inherit pkgs; },
}:

let
  inherit (pkgs) lib;
in
rec {
  nixosModules.lanzaboote =
    { config, ... }:
    {
      imports = [ ./nix/modules/lanzaboote.nix ];
      boot.lanzaboote.package = lib.mkDefault (
        if config.boot.lanzaboote.bootloader == "refind" then packages.lzbt-refind else packages.lzbt
      );
    };

  packages = lib.recurseIntoAttrs (
    import ./nix/packages {
      inherit pkgs crane rust-overlay;
    }
  );

  docs = lib.recurseIntoAttrs {
    html = pkgs.callPackage ./nix/html-docs.nix { };
    options = import ./nix/option-docs.nix {
      inherit pkgs nixosModules;
    };
  };

  checks = lib.recurseIntoAttrs {
    stub = lib.recurseIntoAttrs {
      package = packages.stub;
      inherit (packages.stub.tests)
        clippy
        rustfmt
        ;
    };

    lzbt = lib.recurseIntoAttrs {
      package = packages.stub;
      inherit (packages.stub.tests)
        clippy
        rustfmt
        ;
    };

    lzbt-refind = lib.recurseIntoAttrs {
      package = packages.lzbt-refind;
      inherit (packages.lzbt-refind.tests)
        clippy
        rustfmt
        ;
    };

    docs = lib.recurseIntoAttrs {
      inherit (docs)
        html
        options
        ;
    };

    pre-commit = import ./nix/pre-commit.nix { inherit pkgs; };

    tests = lib.recurseIntoAttrs (
      import ./nix/tests {
        inherit pkgs;
        extraBaseModules = {
          inherit (nixosModules) lanzaboote;
        };
      }
    );
  };

  passthru = { inherit pkgs; };
}
