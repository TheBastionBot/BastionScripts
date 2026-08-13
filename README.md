<div align="center">
  <img alt="Bastion Installer" src="https://i.imgur.com/Fs2QcSw.png">
</div>

<div align="center">

  ### Installer scripts for [Bastion](https://github.com/TheBastionBot/Bastion)

  They install Node.js and the packages Bastion needs, then set Bastion up in your home directory.

</div>

## Install

| Script | Operating system | Package manager |
| --- | --- | --- |
| `linux/apt.sh` | Debian, Ubuntu | apt |
| `linux/dnf.sh` | Fedora, RHEL 8+ | dnf |
| `linux/yum.sh` | RHEL 7, CentOS 7 | yum |
| `linux/pacman.sh` | Arch | pacman |
| `darwin/brew.sh` | macOS | Homebrew |
| `windows/chocolatey.ps1` | Windows | Chocolatey |

The examples use `linux/apt.sh`. Swap in the script for your system.

### Linux & macOS

```bash
curl -fsSL https://raw.githubusercontent.com/TheBastionBot/BastionScripts/main/linux/apt.sh | bash
```

Or download it and run it yourself:

```bash
curl -fsSLO https://raw.githubusercontent.com/TheBastionBot/BastionScripts/main/linux/apt.sh
chmod +x apt.sh
./apt.sh
```

You'll be asked for your password. `sudo` is used to install system packages, never for
anything inside your home directory. `pacman` doesn't support partial upgrades, so
`pacman.sh` upgrades the whole system first.

Node.js is installed with [fnm](https://github.com/Schniz/fnm), which hooks into your
shell profile. Source your shell profile or open a new terminal before you run `node` or
`npm`.

### Windows

Run PowerShell as administrator. The installer exits if it isn't elevated.

```powershell
irm https://raw.githubusercontent.com/TheBastionBot/BastionScripts/main/windows/chocolatey.ps1 | iex
```

## After installing

Bastion won't start until it's configured. Add your bot's token, ID, owners and MongoDB
URI to `settings.yaml` in the installation directory.

An existing installation is moved to `$HOME/Bastion-Old` before the new one is set up, so
you can go back to it.

## Help

Join [Bastion HQ](https://discord.gg/fzx8fkt) and our support staff will help you out.
