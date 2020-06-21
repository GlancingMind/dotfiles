# This is work in progress and currently not tested!

# Notes for me

1. Connect to network via:

   $ wpa_passphrase 'SSID' 'KEY' > passphrase.txt
   $ wpa_supplicant -B -i <interface> -c passphrase.txt # Interface could be wlp3s0

2. Call install.sh in machine/base to partitioning disk
3. Copy this installation information over to root directory.
4. Reboot and login to root
5. reconnect to network like in step 1.
6. use Makefile targets to run nixops (install real os)
7. copy this stuff to user/sascha

TODO

- define Backup target in Makefile
- create symlink from dmenu to bemenu, so passmenu will work under wayland
    e.g. https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=bemenu-dmenu
