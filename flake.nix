{
  inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; 
#     nixpkgs.url = "https://releases.nixos.org/nixos/unstable";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-cosmic }: {
    nixosConfigurations = {
      # Use your actual hostname instead of "nixos"
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; # Ensure this matches your architecture
        modules = [
          {
            nix.settings = {
              substituters = [ "https://cosmic.cachix.org/" ];
              trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
          }
          nixos-cosmic.nixosModules.default
          ./configuration.nix
	  #./modules/asus.nix
  	  (builtins.path { path = "/etc/nixos/modules/asus.nix"; })
        ];
      };
    };
  };
}

