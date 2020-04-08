.POSIX:

home: link-personal-config
	nix-shell --run 'home-manager switch'

link-personal-config:
	-mkdir -p $(HOME)/.config
	-ln -s -n $(PWD)/user $(HOME)/.config/nixpkgs

update-machine-config:
	nix-shell --run 'nixops modify -d laptop machine/laptop/deployment.nix'
	nix-shell --run 'nixops deploy -d laptop'

setup-machine-config: machine/laptop/deployment.nix
	nix-shell --run 'nixops create -d laptop $?'
