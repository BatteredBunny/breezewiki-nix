# breezewiki-nix

```bash
nix run github:BatteredBunny/breezewiki-nix
```

# Installing on NixOS

```nix
# flake.nix
inputs = {
    breezewiki-nix.url = "github:BatteredBunny/breezewiki-nix";
};
```

```nix
# configuration.nix
imports = [
    inputs.breezewiki-nix.nixosModules.default
];

nixpkgs.overlays = [
    inputs.breezewiki-nix.overlays.default
];

services.breezewiki = {
    enable = true;
    settings = {
        port = 10416;
        canonical_origin = "https://breezewiki.example.com"
    };
};
```