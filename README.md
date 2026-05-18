# Dotfiles

This repository contains my personal dotfiles, which are my configuration files for various programs and tools I use, managed with GNU Stow.

> [!IMPORTANT]
> Several packages are integrated into many configs. The dotfiles in this repo should be used as inspiration, and you may need to modify them to fit your needs.

## How it works

Each package has a directory structure and config files mirroring where it should live in your home directory. Stow will create symlinks from these files to there, allowing you to track changes to all of your config files in this repository and only needing to update them in one place. 

## Get started

- Clone this repository in your home folder
- Navigate to the repository folder: 
  ```bash
  cd dotfiles
  ```
- Install GNU stow. You can install it with your package manager, for example:
  ```bash
  sudo apt install stow
  ```
- Set up the stow global ignore file (do this before stowing anything else):
  ```bash
  stow stow
  ```
- Create common config directories:
  ```bash
  mkdir -p ~/.local/bin ~/.config
  ```
- Stow the package you want to use: 
  ```bash
  stow <package_name>
  ```
  Example: 
  ```bash
  stow fish
  ```
- Install the packages you would like on your system. It's a good idea to do this after stowing, otherwise you'll get conflicts with configs that are automatically created during package installation. Note that installation of packages is not handled yet, so you will need to do this manually. See `./packages` for a list of packages and where to get them.

## Adding new configurations

1. Create a new directory with the same name as the program in this repository: 
  ```bash
  mkdir -p btop/
  ```
2. Place configuration files in this directory, maintaining the same structure as they would have in your home directory

Consider using `adopt` to quickly add a new directory to the dotfiles repository:
```bash
stow --adopt fish
stow -n --adopt fish # dry run
```

### Unstow

Remove all symlinks for a particular directory:
```bash
stow -D fish
stow -n -D fish
```
