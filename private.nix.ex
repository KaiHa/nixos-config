{
  networking.hostName = "example.com";
  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.ports = [ 42 ];
}
