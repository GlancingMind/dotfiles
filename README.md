# This is work in progress!

# Base Installation

1. Connect to network via:
    ```console
    $ wpa_passphrase 'SSID' 'KEY' > passphrase.txt
    $ wpa_supplicant -B -i <interface> -c passphrase.txt # Interface could be wlp3s0
    ```
2. Call install.sh in machine/base to partitioning disk
3. Copy this installation information over to root directory.
4. Reboot and login to root
5. reconnect to network like in step 1.
6. use Makefile targets to run nixops (install real os)
7. copy this stuff to user/<new-users-name>

# Setup and update machine configuration

```console
$ make setup-machine-config
$ make update-machine-config
```

# Setup home environment

## Update nixpkgs, home-manager,... individually or all at once

```shell
$ nix-shell --run "niv update nixpkgs"
$ nix-shell --run "niv update home-manager"
$ nix-shell --run "niv update" # all at once
```

## Track new nixpkgs branch

```shell
$ nix-shell --run "niv update nixpkgs -b nixos-19.09"
```
