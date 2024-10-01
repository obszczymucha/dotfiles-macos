export FZF_DEFAULT_OPTS=" \
--bind=alt-q:close,alt-j:down,alt-k:up \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

eval "$(fzf --zsh)"
