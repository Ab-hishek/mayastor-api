{ profile ? "nightly", date ? "2022-06-22" }:
let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs {
    overlays = [ (_: _: { inherit sources; }) (import ./nix/overlay.nix { }) ];
  };
  rust = import sources.nixpkgs { overlays = [ (import sources.rust-overlay) ]; };
in
with pkgs;
pkgs.mkShell {
  buildInputs = [
    cargo-udeps
    clang
    commitlint
    git
    openssl
    pkg-config
    pre-commit
    protobuf
    (rust.rust-bin.${profile}.${date}.default.override {
      extensions = [ "rust-src" ];
    })
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  PROTOC = "${protobuf}/bin/protoc";
  PROTOC_INCLUDE = "${protobuf}/include";
  NODE_PATH = "${nodePackages."@commitlint/config-conventional"}/lib/node_modules";

  shellHook = ''
    pre-commit install
    pre-commit install --hook commit-msg
  '';
}
