# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/d34bccec-e3ac-4e4c-9737-c64875025155";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."crypt".device = "/dev/disk/by-uuid/949a0af8-afd4-44c2-bf46-a06cb05325f5";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/6A6B-B6D7";
      fsType = "vfat";
    };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = "powersave";
}
