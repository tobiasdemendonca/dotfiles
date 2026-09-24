# Zellij

The config uses a custom `terminal` theme that only uses the terminal's 16
colours (0-15). On Omarchy, kitty's palette follows the Omarchy theme, so
zellij changes theme along with the rest of the system, live, without a restart.

## Not on Omarchy

Only stow this package on Omarchy. Elsewhere, the `terminal` theme would pick up
kitty's fallback palette (Catppuccin) instead of night-owl.

On a machine without Omarchy, either:

- don't stow `zellij`, so zellij uses its built-in defaults, or
- stow it and change `theme "terminal"` to `theme "night-owl"` in
  `.config/zellij/config.kdl` on that machine (don't commit the change).

Existing sessions keep the theme they started with; start a new session
(detaching and reattaching isn't enough) to pick up config changes.
