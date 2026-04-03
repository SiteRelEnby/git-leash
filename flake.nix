{
  description = "A git commit hook to block commits in certain repos based on configurable time windows.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages."${system}";
        in
        {
          default =
            pkgs.stdenv.mkDerivation {
              pname = "git-leash";
              version = "0.1.1";

              src = ./.;

              installPhase = ''
                runHook preInstall
                mkdir -p $out/bin/
                cp $src/leash $out/bin/
                chmod +x $out/bin/leash
                runHook postInstall
              '';
            };

        }
      );
    };
}
