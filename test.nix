{ self, testers }:
testers.nixosTest {
  name = "breezewiki";

  interactive.nodes.machine = {
    virtualisation.forwardPorts = [
      {
        from = "host";
        host.port = 8888;
        guest.port = 8888;
      }
    ];
  };

  nodes.machine =
    { ... }:
    {
      imports = [
        self.nixosModules.default
      ];

      nixpkgs.overlays = [
        self.overlays.default
      ];

      services.breezewiki = {
        enable = true;
        openFirewall = true;
        settings.port = 8888;
      };
    };

  testScript =
    { nodes, ... }:
    let
      port = toString nodes.machine.services.breezewiki.settings.port;
    in
    ''
      start_all()
      machine.wait_for_unit("breezewiki.service")
      machine.wait_for_open_port(${port})
      machine.succeed("curl -f http://localhost:${port}/")
      machine.succeed("curl -f http://localhost:${port}/twinpeaks/wiki/Twin_Peaks_Wiki")
    '';
}
