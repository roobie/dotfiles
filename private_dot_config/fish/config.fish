set -gx EDITOR nvim
set -gx VISUAL nvim

if status is-interactive
    # Commands to run in interactive sessions can go here
    # Defensive source: ~/.local/bin/env.fish is install-time-generated
    # by uv. Absent on machines (e.g. dev VMs) where uv wasn't installed.
    test -e $HOME/.local/bin/env.fish; and source $HOME/.local/bin/env.fish
    #source $HOME/.cargo/env.fish
end

# pnpm
set -gx PNPM_HOME "$HOME/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
# bun end

# mise
mise activate fish | source
# mise end

#zoxide init fish | source
