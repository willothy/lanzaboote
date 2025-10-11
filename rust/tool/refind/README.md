# lzbt-refind

rEFInd backend for Lanzaboote.

This tool installs Unified Kernel Images (UKIs) with Secure Boot signing for NixOS using the rEFInd bootloader.

## Overview

`lzbt-refind` is similar to `lzbt-systemd`, but it uses [rEFInd](https://www.rodsbooks.com/refind/) as the bootloader instead of systemd-boot. It:

- Signs the rEFInd bootloader with your Secure Boot keys
- Creates and signs UKIs for each NixOS generation
- Installs all necessary files to the ESP
- Manages garbage collection of old boot files

## Usage

To use rEFInd with Lanzaboote, set the `bootloader` option in your NixOS configuration:

```nix
boot.lanzaboote = {
  enable = true;
  pkiBundle = "/var/lib/sbctl";
  bootloader = "refind";
};
```

## Architecture

The rEFInd backend follows the same structure as the systemd backend:

- `architecture.rs` - Architecture-specific helpers for rEFInd filenames
- `esp.rs` - ESP path management for rEFInd files
- `install.rs` - Main installation logic
- `cli.rs` - Command-line interface

The main difference from the systemd backend is that it installs rEFInd instead of systemd-boot and uses `refind.conf` instead of `loader.conf`.
