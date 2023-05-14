{% if grains.os_family == 'Debian' %}
dpkg --add-architecture i386:
  cmd.run:
    - unless: "dpkg --print-foreign-architectures | grep 'i386'"
# Thanks man dpkg

apt-get update && apt-get install wine32:
  cmd.run:
    - unless: "apt-get install wine32 | grep 'is already the newest version'"

packages_required:
  pkg.installed:
    
      - pkgs:
        - blender
        - ufw
        - wine
        - micro
        
steam_install:
  pkg.installed:
    - sources:
      - steam-launcher: https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb

# Didn't figure out a more sensible way to do this, so many cmd.run's it is.
# Ports 4505 & 4506 are salt ports, might want to disable them later if ran locally.
# They're added just in case the script is used from a master on a slave so that the installation doesn't explode midway through.
# Feel free to comment them out.

ufw allow 22/tcp:
  cmd.run:
    - unless: "ufw status | grep '22/tcp'"

ufw allow 80/tcp:
  cmd.run:
    - unless: "ufw status | grep '80/tcp'"

ufw allow 4505/tcp:
  cmd.run:
    - unless: "ufw status | grep '4505/tcp'"

ufw allow 4506/tcp:
  cmd.run:
    - unless: "ufw status | grep '4506/tcp'"

ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"

{% elif grains.os_family == 'Windows' %}

packages.required:
  pkg.installed:
    - pkgs:
      - micro
      - blender

{% endif %}
