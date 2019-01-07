# Node.js environment

{ nixpkgs ? import <nixpkgs> {} }:

# Node.js runtime
{
  node = nixpkgs.nodejs-10_x;
}
