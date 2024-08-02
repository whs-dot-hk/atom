{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    treefmt
    npins
    nixfmt-rfc-style
    shfmt
  ];
}
