.POSIX:

BACKUP_DIR = $(HOME)/backup

home: user/home.nix
	nix-shell --command "home-manager -f $? switch"

update-machine-config: machine/laptop/deployment.nix
	nix-shell --run 'nixops modify -d laptop $?'
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

