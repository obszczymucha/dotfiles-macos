# shellcheck disable=1090,1091
export DOTFILES_DIR="$HOME/.dotfiles/current"
export SCRIPTS_DIR="$DOTFILES_DIR/Scripts"
export ZSHRC_DIR="$DOTFILES_DIR"/zshrc
export PATH="${HOMEBREW_PREFIX}/opt/openssl/bin:$SCRIPTS_DIR:$HOME/.cargo/bin:$PATH:""/Applications/IntelliJ IDEA CE.app/Contents/MacOS"

source "$ZSHRC_DIR/proxy.sh"
source "$ZSHRC_DIR/tmux.sh"
source "$ZSHRC_DIR/zinit-setup.sh"
source "$ZSHRC_DIR/plugins.sh"
source "$ZSHRC_DIR/fzf.sh" # Put fzf before completion, so it utilises the settings.
source "$ZSHRC_DIR/completion.sh"
source "$ZSHRC_DIR/colors.sh"
source "$ZSHRC_DIR/help.sh"
source "$ZSHRC_DIR/general-purpose.sh"
source "$ZSHRC_DIR/git.sh"
source "$ZSHRC_DIR/haskell.sh"
source "$ZSHRC_DIR/navigation.sh"
source "$ZSHRC_DIR/remap.sh"
source "$ZSHRC_DIR/sdkman.sh"
source "$ZSHRC_DIR/zoxide.sh"
source "$ZSHRC_DIR/prompt.sh"
source "$ZSHRC_DIR/host-specific.sh"
source "$ZSHRC_DIR/todo.sh"

if [[ -f "$ZSHRC_DIR/work.sh" ]]; then
  source "$ZSHRC_DIR/work.sh"
fi

