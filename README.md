# Base Installation

1. Connect to network via:
    ```console
    $ wpa_passphrase 'SSID' 'KEY' > passphrase.txt
    $ wpa_supplicant -B -i <interface> -c passphrase.txt # Interface could be wlp3s0
    ```
2. Call install.sh in machine/base to partition disk.
3. Copy this installation information over to root directory.
4. Reboot and login to root.
5. reconnect to network like in step 1.
6. Run ```$ make switch``` to install nixos.
7. Delete or copy this while directory over to a diffrent user directory.

# Update machine configuration

```shell
$ make switch
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
