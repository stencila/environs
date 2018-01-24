{ nixpkgs }:

with nixpkgs.pythonPackages; [
  scikitimage
  scikitlearn
  scipy
  seaborn
]
