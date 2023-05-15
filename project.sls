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

# Start of Windows section. Does not check for windows version. Tested on W10 & W11
{% elif grains.os_family == 'Windows' %}

packages.required:
  pkg.installed:
    - pkgs:
      - blender
      - 7zip
      - git
      - putty

# The actual solution to below mess would be to pass each package as a string/object to winget un/install, or toss it all in a seperate shell file
# Also for some reason && chaining of commands doesn't seem to work in PowerShell

winget install "Notepad++.Notepad++"":
  cmd.run

winget install "GIMP.GIMP":
  cmd.run

winget install "Mozilla.Firefox":
  cmd.run

winget install "Discord.Discord":
  cmd.run

winget install "GOG.Galaxy":
  cmd.run

winget uninstall "Clipchamp":
  cmd.run

winget uninstall "Cortana":
  cmd.run

winget uninstall "Windows Maps":
  cmd.run

PolicyChanges:
  lgpo.set:
    - computer_policy:
        Do not show Windows tips: Enabled
        Deny log on locally:
          - Guest
        Turn off cloud optimized content: Enabled
        Do not include drivers with Windows Updates: Enabled
        Allow the use of biometrics: Disabled
        Minimum password length: 12
        Store passwords using reversible encryption: Disabled
        Disable OneSettings Downloads: Enabled
        Do not show feedback notifications: Enabled
        Turn off hybrid sleep (plugged in): Enabled
        Turn off the advertising ID: Enabled

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power:
  reg.present:
    - vname: HiberbootEnabled
    - vtype: REG_DWORD
    - vdata: 0
    
# Host file contents from https://winhelp2002.mvps.org/hosts.txt 

C:\Windows\System32\drivers\etc\hosts:
  file.managed:
    - source: salt://PCSetupProject/hosts

{% endif %}
