{ pkgs, config, ... }:

with pkgs; {
  services = {

    dbus = {
      enable = true;
    };

    fstrim = {
      enable = true;
    };

    journald.extraConfig = "SystemMaxUse=128M";

    nullmailer = {
      enable = true;
      config.allmailfrom = "postmaster.rob@gmail.com";
      remotesFile = "/etc/nullmailer.remotes";
    };

    openssh = {
      enable = true;
      challengeResponseAuthentication = false;
      passwordAuthentication = false;
      permitRootLogin = "no";
    };

    pcscd.enable = true;
    physlock.enable = true;

    printing = {
      drivers = [ gutenprint ];
      enable = true;
    };

    dnsmasq = {
      enable = true;
      servers = [ "127.0.0.1#53000" ];
    };

    resolved.enable = false;
    stubby = {
      enable = true;
      listenAddresses = [ "127.0.0.1@53000"
                          "0::1@53000" ];
    };

    spice-vdagentd.enable = true;
    vnstat.enable = true;

    xserver = {
      enable = true;
      layout = "us";
      displayManager.slim = {
        enable = true;
        defaultUser = "kai";
        autoLogin = false;
        extraConfig = ''
          sessionstart_cmd    ${xorg.sessreg}/bin/sessreg -a -l tty7 %user
          sessionstop_cmd     ${xorg.sessreg}/bin/sessreg -d -l tty7 %user
        '';
      };
      desktopManager.default = "none";
      windowManager = {
        default = "xmonad";
        xmonad.enable = true;
      };
    };
  };
}
