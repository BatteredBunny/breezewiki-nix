{
  pkgs,
  config,
  lib,
  ...
}:

let
  cfg = config.services.breezewiki;

  envVariables = lib.mapAttrsToList (n: v: "BW_${lib.toUpper n}=${toString v}") cfg.settings;
in
{
  options.services.breezewiki = {
    enable = lib.mkEnableOption "BreezeWiki";

    package = lib.mkPackageOption pkgs "breezewiki" { };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to open the firewall for the BreezeWiki port.";
    };

    settings = lib.mkOption {
      description = ''
        Configuration for BreezeWiki.
        See https://docs.breezewiki.com/Configuration.html for details.
      '';
      default = { };
      type = lib.types.submodule {
        freeformType = (pkgs.formats.ini { }).type;

        options = {
          bind_host = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Hostname to run the server on. 'auto' means 127.0.0.1 in debug, otherwise all interfaces.";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = 10416;
            description = "The port BreezeWiki should listen on.";
          };

          canonical_origin = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "https://breezewiki.example.com";
            description = "The primary URL for the instance homepage.";
          };

          debug = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Enable verbose output and disable some browser caching.";
          };

          feature_search_suggestions = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to send search box text to Fandom for suggestions.";
          };

          log_outgoing = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to log outgoing requests to Fandom to the console.";
          };

          strict_proxy = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to proxy stylesheets and images to reduce direct connections to Fandom.";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [
      cfg.settings.port
    ];

    systemd.services.breezewiki = {
      description = "BreezeWiki";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}";
        WorkingDirectory = "/var/lib/breezewiki";
        StateDirectory = "breezewiki";
        Restart = "always";
        DynamicUser = true;

        Environment = envVariables;

        ProtectSystem = "strict";
        ProtectHome = "yes";
        LockPersonality = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };
    };
  };
}
