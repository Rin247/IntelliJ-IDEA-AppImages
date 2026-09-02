# IntelliJ IDEA AppImages

[![Latest](https://img.shields.io/endpoint?url=https%3A%2F%2Fraw.githubusercontent.com%2FRin247%2Fintellij-idea-appimages%2Fdist-badges%2Fbadge-latest.json)](https://github.com/Rin247/intellij-idea-appimages/releases/latest)
[![Release](https://github.com/Rin247/intellij-idea-appimages/actions/workflows/release.yml/badge.svg)](https://github.com/Rin247/intellij-idea-appimages/actions/workflows/release.yml)
[![Badges](https://github.com/Rin247/intellij-idea-appimages/actions/workflows/badges.yml/badge.svg)](https://github.com/Rin247/intellij-idea-appimages/actions/workflows/badges.yml)

Packages [IntelliJ IDEA Community](https://www.jetbrains.com/idea) as AppImages.

AppImages are directly created from `.tar.gz` builds and are not decompiled or modified. AppImages are compiled in Ubuntu 22.04 (minimum). Only the latest stable release of IntelliJ IDEA Community is packaged.

## Supported Builds

-   AMD64

## Installation

### Pho

This command requires [Pho](https://github.com/zyrouge/pho) to be installed.

```bash
pho install github --id intellij-idea-community Rin247/intellij-idea-appimages
```

### Manual

Can be directly downloaded from Github Releases and integrated using tools like AppImageLauncher.

## Minimum distribution support

This project builds AppImages using an Ubuntu 22.04 (jammy) chroot/container as the minimum supported build environment. Support for older distributions (Ubuntu 20.04 and earlier) has been removed.

## Arch Linux

Two options are provided for Arch users:

- Run the distributed AppImage directly on Arch. AppImages produced by this project bundle required libraries so they should run on Arch Linux; use AppImageLauncher or run the file directly (make it executable and execute).
- Build a native Arch package from JetBrains' upstream tarball. See [Arch's wiki](https://wiki.archlinux.org/title/IntelliJ_IDEA) for `intellij-idea-community-edition` in the AUR.