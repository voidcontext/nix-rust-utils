# Changelog
All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

- - -
## v0.10.0 - 2023-11-24
#### Bug Fixes
- allow passing environment variables to the dev shell (#12) - (34c8e07) - Gabor Pihaj
- remove sourceFilter from args before passing to cargo checks (#11) - (2ceb394) - Gabor Pihaj
#### Features
- add ability to skip building dependencies as standalone derivation (#10) - (56cb702) - Gabor Pihaj

- - -

## v0.9.0 - 2023-10-19
#### Bug Fixes
- handle cargo clippy extra args (#9) - (1b5fdf0) - Gabor Pihaj
#### Features
- add ability to change the default source filter (#3) - (d9abc3d) - Gabor Pihaj

- - -

## v0.8.3 - 2023-10-08
#### Bug Fixes
- propagate build inputs correctly in wasm derivations (#8) - (c29f589) - Gabor Pihaj

- - -

## v0.8.2 - 2023-10-06
#### Bug Fixes
- remove unused flake input (nixpkgs unstable) (#5) - (917db73) - Gabor Pihaj
#### Build system
- run CI on PRs and when pushed to main (#6) - (6ee0c10) - Gabor Pihaj
- use nix-attic woodpecker plugin and attic cache (#4) - (f9778cc) - Gabor Pihaj
#### Miscellaneous Chores
- update nixpkgs (#7) - (7fe4a02) - Gabor Pihaj

- - -

## v0.8.1 - 2023-09-26
#### Bug Fixes
- make sure cargo deps are the same in mkCrate and mkChecks - (f57b383) - Gabor Pihaj
#### Miscellaneous Chores
- reformat files - (0e56ea7) - Gabor Pihaj
#### Refactoring
- implement mkDevShell using crane - (e13a5bf) - Gabor Pihaj

- - -

## v0.8.0 - 2023-07-13
#### Continuous Integration
- use woodpecker-ci instead of githb actions - (437fea8) - Gabor Pihaj
#### Features
- simplify API by using latest crane (v0.12.2) - (bec5239) - Gabor Pihaj

- - -

## v0.7.0 - 2023-07-05
#### Bug Fixes
- example code - (3892194) - Gabor Pihaj
#### Continuous Integration
- **(github)** upgrade cachix action - (dd2c979) - Gabor Pihaj
#### Features
- allow omitting buildInputs - (8546866) - Gabor Pihaj
- add cargo-edit to the dev shell - (22fbc7f) - Gabor Pihaj
#### Miscellaneous Chores
- update nixpkgs and nixpkgs-unstable - (09a9d76) - Gabor Pihaj
- reformat code - (605beeb) - Gabor Pihaj
- start using cog and conventional commits - (ddf55ef) - Gabor Pihaj

- - -

Changelog generated by [cocogitto](https://github.com/cocogitto/cocogitto).