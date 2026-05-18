if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting           # Supresses fish's intro msg

# Start Starship for a fancy prompt
starship init fish | source

# Yazi (browsing files)
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end

# Kitty term colour
function lxc --wraps lxc
    if test "$argv[1]" = "shell"
        env TERM=xterm-256color /snap/bin/lxc $argv
    else
        /snap/bin/lxc $argv
    end
end

# Kitty SSH colour
if set -q KITTY_WINDOW_ID
    alias ssh 'TERM=xterm-256color /usr/bin/ssh'
end

# NVM (node)
set -gx NVM_DIR "$HOME/.nvm"
set PATH "$HOME/.nvm/versions/node/v24.11.1/bin" $PATH
set -Ux EZA_CONFIG_DIR "$HOME/.config/eza"
set -Ux MANPAGER "batcat -l man -p"
