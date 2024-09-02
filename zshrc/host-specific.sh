# shellcheck disable=1091
case "$ZSH_PROMPT_HOSTNAME_TAG" in
  "msi")
    source "$ZSHRC_DIR/msi.zsh"
    ;;
  "wsl")
    source "$ZSHRC_DIR/windows.sh"
    ;;
  "xps13")
    source "$ZSHRC_DIR/xps13.sh"
    ;;
  "cba")
    source "$ZSHRC_DIR/cba.sh"
    ;;
esac

