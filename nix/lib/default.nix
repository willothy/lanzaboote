{
  # Utility function to fetch rEFInd themes from GitHub
  # Usage: lanzaboote.lib.fetchRefindTheme { pkgs, lib, owner, repo, rev, sha256, ... }
  fetchRefindTheme =
    { pkgs
    , lib
    , owner
    , repo
    , rev
    , sha256
    , themeName ? repo
    , themeSubdir ? null
    }:
    let
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev sha256;
      };
      themeDir = if themeSubdir != null then "${src}/${themeSubdir}" else src;
    in
    lib.mapAttrs'
      (name: type:
        lib.nameValuePair
          "themes/${themeName}/${name}"
          "${themeDir}/${name}"
      )
      (builtins.readDir themeDir);
}
