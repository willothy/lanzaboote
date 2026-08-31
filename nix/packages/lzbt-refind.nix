{
  lib,
  buildRustApp,
  makeBinaryWrapper,
  binutils-unwrapped,
  sbsigntool,
  stub,
}:

buildRustApp {
  pname = "lzbt-refind";
  src = lib.sourceFilesBySuffices ../../rust/tool [
    ".rs"
    ".toml"
    ".lock"
    # Test fixtures
    ".pem"
    ".key"
  ];
  packages = [ "lzbt-refind" ];
  packageArgs = {
    nativeBuildInputs = [
      makeBinaryWrapper
    ];

    nativeCheckInputs = [
      binutils-unwrapped
      sbsigntool
    ];

    postInstall =
      let
        path = lib.makeBinPath [
          binutils-unwrapped
          sbsigntool
        ];
      in
      ''
        wrapProgram $out/bin/lzbt-refind \
          --prefix PATH : ${path} \
          --set LANZABOOTE_STUB ${stub}/bin/lanzaboote_stub.efi
      '';

    meta.mainProgram = "lzbt-refind";
  };
}
