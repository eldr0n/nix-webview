{ config, lib, pkgs, ... }:

let
  cfg = config.programs.nix-webview;
  system = pkgs.stdenv.hostPlatform.system;
  makeWebviewAppBuilder = import ../../pkgs/webview-webapp;
  makeWebviewApp = makeWebviewAppBuilder { inherit pkgs lib; };

  webappOptions = { name, ... }: {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "The name of the webview application.";
      };
      url = lib.mkOption {
        type = lib.types.str;
        description = "The URL to load in the webview.";
      };
      title = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Window title.";
      };
      width = lib.mkOption {
        type = lib.types.int;
        default = 800;
        description = "Initial window width.";
      };
      height = lib.mkOption {
        type = lib.types.int;
        default = 600;
        description = "Initial window height.";
      };
      fullscreen = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to start in fullscreen.";
      };
      qt = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Use Qt backend instead of GTK.";
      };
      icon = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to an icon file, icon name, or a URL to an image.";
      };
      iconHash = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Hash for the remote icon.";
      };
      userAgent = lib.mkOption {
        type = lib.types.str;
        default = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
        description = "User agent for the webview application.";
      };
      desktopName = lib.mkOption {
        type = lib.types.str;
        description = "Name for the desktop entry.";
      };
      genericName = lib.mkOption {
        type = lib.types.str;
        default = "Web Application";
        description = "Generic name for the desktop entry.";
      };
      categories = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "WebBrowser" ];
        description = "Desktop categories.";
      };
    };
    config.desktopName = lib.mkDefault name;
  };

in
{
  options.programs.nix-webview = {
    enable = lib.mkEnableOption "nix-webview applications";
    
    webapps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule webappOptions);
      default = {};
      description = "Declarative webview applications to install.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.mapAttrsToList (name: appCfg: 
      makeWebviewApp {
        inherit (appCfg) name url title width height fullscreen qt icon iconHash userAgent desktopName genericName categories;
      }
    ) cfg.webapps;
  };
}
