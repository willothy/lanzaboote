{
  name = "lanzaboote-refind";

  nodes.machine = {
    imports = [ ./common/lanzaboote.nix ];

    boot.lanzaboote.bootloader = "refind";

    # rEFInd does not implement systemd-boot's /loader/keys/auto enrollment,
    # so the firmware stays in setup mode. The artifacts are still signed;
    # this test covers the handoff, not Secure Boot enforcement.
    lanzabooteTest.keyFixture = true;
  };

  testScript =
    { nodes, ... }:
    (import ./common/image-helper.nix { inherit (nodes) machine; })
    + ''
      # Reaching userspace at all means the firmware loaded rEFInd, rEFInd
      # parsed its generated config, and the UKI it pointed at executed.
      machine.wait_for_unit("multi-user.target")

      # rEFInd is installed where the firmware and the fallback path expect it.
      machine.succeed("test -s /boot/EFI/refind/BOOTX64.EFI")
      machine.succeed("test -s /boot/EFI/BOOT/BOOTX64.EFI")

      # Every generation the generated config offers must actually exist,
      # otherwise the entry is a dead end at the menu.
      refind_conf = machine.succeed("cat /boot/EFI/refind/refind.conf")
      print(refind_conf)

      loaders = [
          line.split()[1].replace("\\", "/").lstrip("/")
          for line in refind_conf.splitlines()
          if line.strip().startswith("loader ")
      ]
      t.assertNotEqual(loaders, [], "generated refind.conf offers no entries")
      for loader in loaders:
          machine.succeed(f"test -s /boot/{loader}")

      # The UKIs must be real UKIs, the same bar the systemd-boot path is held to.
      t.assertIn(
          "Kernel Type: uki",
          machine.succeed("bootctl kernel-inspect /boot/EFI/Linux/nixos-generation-1-*.efi"),
      )
    '';
}
