{ config, lib, pkgs, ... }:
let
  inherit (lib) concatMapStringsSep concatStringsSep isAttrs isInt isList
    isString literalExpression mapAttrsToList mdDoc mkEnableOption mkIf
    mkOption mkRemovedOptionModule types;
  inherit (lib.types) attrsOf bool either int lines listOf oneOf str;

  prefixStringLines = prefix: str:
    concatMapStringsSep "\n" (line: prefix + line) (lib.splitString "\n" str);
  indent = prefixStringLines "  ";

  toplevel = attrsOf section;
  section = attrsOf relation;
  relation = either (attrsOf value) value;
  value = either (listOf atom) atom;
  atom = oneOf [int str bool];

  formatToplevel = toplevel: concatStringsSep "\n" (mapAttrsToList formatSection toplevel);
  formatSection = name: section: ''
    [${name}]
    ${indent (concatStringsSep "\n" (mapAttrsToList formatRelation section))}
  '';
  formatRelation = name: relation:
    if isAttrs relation
    then ''
      ${name} = {
      ${indent (concatStringsSep "\n" (mapAttrsToList formatValue relation))}
      }
    ''
    else formatValue name relation;
  formatValue = name: value:
    if isList value
    then "${name} = ${concatMapStringsSep " " formatAtom value}"
    else "${name} = ${formatAtom value}";
  formatAtom = atom:
    if atom == true
    then "true"
    else if atom == false
    then "false"
    else if isInt atom
    then toString atom
    else if isString atom
    then atom
    else throw "unreachable";

  mkRemovedOptionModule' = name: reason: mkRemovedOptionModule ["krb5" name] reason;
  mkRemovedOptionModuleCfg = name: mkRemovedOptionModule' name ''
    The option `krb5.${name}' has been removed. Use `krb5.settings.${name}' for
    structured configuration or `krb5.extraConfig' for plain-text configuration.
  '';
  mkRemovedOptionModuleVeryOld = name: replacement: mkRemovedOptionModule' name ''
    The option `krb5.${name}' has been removed. Replace it with
    `krb5.settings.${replacement}' according to krb5.conf(5).
  '';

  cfg = config.krb5;
in {
  imports = [
    (mkRemovedOptionModuleCfg "libdefaults")
    (mkRemovedOptionModuleCfg "realms")
    (mkRemovedOptionModuleCfg "domain_realm")
    (mkRemovedOptionModuleCfg "capaths")
    (mkRemovedOptionModuleCfg "appdefaults")
    (mkRemovedOptionModuleCfg "plugins")
    (mkRemovedOptionModule' "config" ''
      The option `krb5.config' has been removed. Use `krb5.settings' for
      structured configuration or `krb5.extraConfig' for plain-text
      configuration.
    '')
    (mkRemovedOptionModuleVeryOld "defaultRealm" "libdefaults.default_realm")
    (mkRemovedOptionModuleVeryOld "domainRealm" "domain_realm")
    (mkRemovedOptionModuleVeryOld "kdc" "realms.*.kdc")
    (mkRemovedOptionModuleVeryOld "kerberosAdminServer" "realms.*.admin_server")
  ];

  ###### interface

  options = {
    krb5 = {
      enable = mkEnableOption (lib.mdDoc "building krb5.conf, configuration file for Kerberos V");

      kerberos = mkOption {
        type = types.package;
        default = pkgs.krb5;
        defaultText = literalExpression "pkgs.krb5";
        example = literalExpression "pkgs.heimdal";
        description = lib.mdDoc ''
          The Kerberos implementation that will be present in
          `environment.systemPackages` after enabling this
          service.
        '';
      };

      settings = mkOption {
        default = {};
        description = mdDoc ''
          Structured contents of the `krb5.conf` file. See krb5.conf(5) for
          details about configuration.
        '';
        example = literalExpression ''
          {
            libdefaults = {
              default_realm = "ATHENA.MIT.EDU";
            };

            realms = {
              "ATHENA.MIT.EDU" = {
                admin_server = "athena.mit.edu";
                kdc = [
                  "athena01.mit.edu"
                  "athena02.mit.edu"
                ];
              };
            };

            domain_realm = {
              "example.com" = "EXAMPLE.COM";
              ".example.com" = "EXAMPLE.COM";
            };

            capaths = {
              "ATHENA.MIT.EDU" = {
                "EXAMPLE.COM" = ".";
              };
              "EXAMPLE.COM" = {
                "ATHENA.MIT.EDU" = ".";
              };
            };

            appdefaults = {
              pam = {
                debug = false;
                ticket_lifetime = 36000;
                renew_lifetime = 36000;
                max_timeout = 30;
                timeout_shift = 2;
                initial_timeout = 1;
              };
            };

            plugins = {
              ccselect = {
                disable = "k5identity";
              };
            };
          }
        '';
        type = toplevel;
      };

      extraConfig = mkOption {
        type = lines;
        default = "";
        example = ''
          [logging]
            kdc          = SYSLOG:NOTICE
            admin_server = SYSLOG:NOTICE
            default      = SYSLOG:NOTICE
        '';
        description = lib.mdDoc ''
          These lines go to the end of `krb5.conf` verbatim.
          `krb5.conf` may include any of the relations that are
          valid for `kdc.conf` (see `man kdc.conf`),
          but it is not a recommended practice.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [cfg.kerberos];
      etc."krb5.conf".text = cfg.extraConfig;
    };

    krb5.extraConfig = formatToplevel cfg.settings;
  };
}
