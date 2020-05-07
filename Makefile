.POSIX:

BACKUP_DIR = $(HOME)/backup

home:
	home-manager switch

setup-home-manager: $(HOME)/.config/nixpkgs
	-mkdir -p $(HOME)/.config
	-ln -s -n $(PWD)/nix-channels $(HOME)/.nix-channels
	-ln -s -n $(PWD)/user $(HOME)/.config/nixpkgs
	#-nix-channel --update
	nix-shell '<home-manager>' -A install

update-machine-config: machine/laptop/deployment.nix
	nix-shell --run 'nixops modify -d laptop machine/laptop/deployment.nix'
	nix-shell --run 'nixops deploy -d laptop'

setup-machine-config: machine/laptop/deployment.nix
	nix-shell --run 'nixops create -d laptop $?'

#TODO backup will be always run, or not overriden even when file changed
# should only copy files, which have changed.
backup: $(HOME)/.ssh $(HOME)/.gnupg $(HOME)/.mozilla \
		$(HOME)/.local/share/password-store \
		$(PWD) # this nix-config directory
	mkdir -p $(BACKUP_DIR)
	cp -r $? $(BACKUP_DIR)

