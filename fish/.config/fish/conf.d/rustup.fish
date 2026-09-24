# Created by rustup's own installer (rustup-init), so it is absent on machines
# where rust came from the package manager, or not at all.
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
