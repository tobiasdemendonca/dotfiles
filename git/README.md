# Git

`.gitconfig` contains shared git settings. User-specific config (name, email, signing key) lives in `~/.gitconfig.local`, which is included automatically but not tracked in this repo.

## Setup

Copy the example file and fill in your details:

```bash
cp ~/dotfiles/git/.gitconfig.local.example ~/.gitconfig.local
```

Then edit `~/.gitconfig.local` and fill in the fields with your information. 

### SSH commit signing

The signingkey should point to your public key. To enable verification, add your key to `~/.ssh/allowed_signers`. Note the git namespace which prevents from cross-protocol attacks:

```bash
# Replace <your_key>.pub with the filename of your public key (e.g. id_ed25519.pub)
echo "$(git config --get user.email) namespaces=\"git\" $(cat ~/.ssh/<your_key>.pub)" >> ~/.ssh/allowed_signers
```
