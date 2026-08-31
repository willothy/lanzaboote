# Use rEFInd

By default Lanzaboote installs [systemd-boot][systemd-boot] as the boot
loader. Set `boot.lanzaboote.bootloader` to `"refind"` to use
[rEFInd][refind] instead, a graphical boot manager with theming support.

Both backends sign and install the same Unified Kernel Images. Only the boot
manager placed on the ESP, and the menu it presents, differ.

```nix
{ pkgs, lib, ... }:
{
  environment.systemPackages = [
    # For debugging and troubleshooting Secure Boot.
    pkgs.sbctl
    pkgs.refind
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    bootloader = "refind";
    pkiBundle = "/var/lib/sbctl";
  };
}
```

Switching to this configuration selects the `lzbt-refind` tool instead of
`lzbt`, so `boot.lanzaboote.package` does not need to be set by hand.

## Customizing the menu

`boot.lanzaboote.refind.configTemplate` replaces the base `refind.conf` that
the generated NixOS entries are appended to. Use it when you want full control
over the boot manager's settings:

```nix
boot.lanzaboote.refind.configTemplate = ./refind.conf;
```

[refind]: https://www.rodsbooks.com/refind/
[systemd-boot]: https://www.freedesktop.org/software/systemd/man/latest/systemd-boot.html
