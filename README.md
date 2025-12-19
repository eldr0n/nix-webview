# Nix WebView

A Nix library to create webview webapps using [pywebview](https://github.com/r0x0r/pywebview).
Inspired by [nix-webapps](https://github.com/AniviaFlome/nix-webapps).

## Usage

### In your `flake.nix` (NixOS or Home Manager)

To use it from GitHub:

```nix
{
  inputs = {
    nix-webview.url = "github:eldr0n/nix-webview";
  };

  outputs = { self, nixpkgs, nix-webview }: {
    # Define a package for your system
    packages.x86_64-linux.my-app = nix-webview.lib.x86_64-linux.makeWebviewApp {
      name = "my-app";
      url = "https://example.com";
    };
  };
}
```

### Local Testing (NixOS)

To test it locally with your NixOS configuration without pushing to GitHub, you can use a local path in your `inputs`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-webview.url = "path:/path/to/your/nix-webview"; # Point this to your local clone
  };

  outputs = { self, nixpkgs, nix-webview }: 
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.my-machine = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ pkgs, ... }: {
          environment.systemPackages = [ 
            nix-webview.lib.${system}.makeWebviewApp {
              name = "my-local-app";
              url = "https://nixos.org";
            }
          ];
        })
        # ... your other modules
      ];
    };
  };
}
```

### Home Manager

You can also use it with Home Manager. There are two ways to do this:

#### 1. Using the Home Manager Module (Recommended)

Add the module to your Home Manager configuration and use the declarative options:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nix-webview.url = "github:youruser/nix-webview";
  };

  outputs = { nixpkgs, home-manager, nix-webview, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        nix-webview.homeManagerModules.default
        {
          programs.nix-webview = {
            enable = true;
            webapps.whatsapp = {
              url = "https://web.whatsapp.com";
              # iconHash = "sha256-..."; # Optional but recommended for reproducibility
            };
          };
        }
      ];
    };
  };
}
```

#### 2. Using the library directly

You can also use the `makeWebviewApp` builder within the `home.packages` list:

```nix
{
  # ... inputs same as above
  outputs = { nixpkgs, home-manager, nix-webview, ... }:
  # ...
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ({ pkgs, ... }: {
          home.packages = [
            nix-webview.lib.${system}.makeWebviewApp {
              name = "whatsapp";
              url = "https://web.whatsapp.com";
            }
          ];
        })
      ];
    };
}
```

## Options

- `name`: Name of the package and executable.
- `url`: The URL to load.
- `title`: Window title (defaults to `name`).
- `width`: Initial window width (default: 800).
- `height`: Initial window height (default: 600).
- `fullscreen`: Whether to start in fullscreen (default: false).
- `gtk`: Use GTK backend (default: true).
- `qt`: Use Qt backend (default: false).
- `icon`: Path to an icon file, icon name, or a URL to an image. (Defaults to `https://<domain>/favicon.ico` if not provided).
- `iconHash`: Hash for the remote icon (required if `icon` is a URL or if you rely on the default favicon).
- `desktopName`: Name for the desktop entry.
- `genericName`: Generic name for the desktop entry.
- `categories`: Desktop categories (default: `["Network" "WebBrowser"]`).
