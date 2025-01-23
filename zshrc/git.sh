# shellcheck disable=SC2148
alias glol="git log --pretty=format:'%C(yellow)%h|%Cred%ad|%Cblue%an|%Cgreen%d %Creset%s' --date=short | column -ts'|' | less -r"
alias git_cache_credentials="git config credential.helper cache; git config credential.helper 'cache --timeout 28800'"
alias git_user_init='git config user.email "obszczymucha@gmail.com"; git config user.name "Obszczymucha"'
alias grbom='git rebase origin/master'
alias gitsub="git submodule update --init --recursive"
alias gp > /dev/null && unalias gp
alias tsh='tig show HEAD'
alias gaan='git add --intent-to-add --all && gst'
alias gcp='git cherry-pick'
alias gcpc='git cherry-pick --continue'
alias gcan!='git commit --all --amend --no-edit'
alias grb='git rebase'
alias grbi='git rebase -i'
alias gra='git restore .'
alias gstu='git stash -u'
alias gstp='git stash pop'
alias git_bare_remote_config="git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'"

function white() {
  echo -e "\0033[97m$*\0033[0m"
}

function gc() {
  if [[ -z "$GPG_TTY" ]]; then
    echo "Setting up gpgtty..."
    gpgtty
  fi

  git commit "$@"
}

alias gh="git log -1 --oneline"

function ghash() {
  git rev-parse "$@" HEAD
}

function gp() {
  if [[ $# -gt 1 ]]; then
    local cmd="git push $*"
    echo "Running: $(white "$cmd")" >&2
    eval "$cmd"
    return
  fi

  local branch="$1"

  if [[ -z "$branch" ]]; then
    branch=$(git branch --show-current)
  fi

  local cmd="git push origin $branch"
  echo "Running: $(white "$cmd")" >&2
  eval "$cmd"
}

function filter_empty_args() {
  local result=()

  for arg in "$@"; do
    if [[ -n "$arg" ]]; then
      result+=("$arg")
    fi
  done

  echo "${result[@]}"
}

function home_to_dotfiles() {
  local current_dir
  current_dir=$(pwd)
  local cmd
  cmd=$(filter_empty_args "$@")

  if [[ $current_dir == "$HOME" ]]; then
    cd "$DOTFILES_DIR" || return
    eval "$cmd"
  else
    eval "$cmd"
  fi
}

alias gst > /dev/null && unalias gst
function gst() {
  home_to_dotfiles git status
}

alias gaa > /dev/null && unalias gaa
function gaa() {
  git add --all "$@" && gst
}

alias gpr > /dev/null && unalias gpr
function gpr() {
  local current_dir
  current_dir=$(pwd)

  if [[ $current_dir == "$HOME" ]]; then
    builtin cd "$DOTFILES_DIR" || return
  fi

  local old_head new_head
  old_head=$(git rev-parse HEAD)

  local cmd="git pull --rebase"

  # shellcheck disable=2119
  if [[ ! $(is_git_worktree) && ! $(is_git_bare_repo_worktree) ]]; then
    local branch
    branch=$(git branch --show-current)
    cmd="git pull origin $branch --rebase"
  fi

  echo "Running: $(white "$cmd")"
  eval "$cmd"

  new_head=$(git rev-parse HEAD)

  if [[ $(git log "$old_head..$new_head" --oneline) ]]; then
    white "New commits:"
    git --no-pager log --color --oneline --format="%C(magenta)%h%C(reset) %C(green)%an%C(reset) %s" "$old_head..$new_head"
  fi
}

alias gr > /dev/null && unalias gr
function gr() {
  git reset "$@" && gst
}

alias ga > /dev/null && unalias ga
function ga() {
  git add "$@" && gst
}

function gan() {
  git add --intent-to-add "$@" && gst
}

alias gco > /dev/null && unalias gco
function gco() {
  git checkout "$@" && gst
}

alias gb > /dev/null && unalias gb
alias gb="git --no-pager branch"
alias gbp="git branch"

alias gd > /dev/null && unalias gd
function gd() {
  # shellcheck disable=2119
  if ! is_git_worktree && ! is_git_bare_repo_worktree; then
    echo "Not a git repository." >&2
    return 1
  fi

  if [[ -n "$(home_to_dotfiles git --no-pager diff "$1")" ]]; then
    home_to_dotfiles git --no-pager diff "$1" | tig
  else
    echo "No changes to show." >&2
  fi
}

function gds() {
  # shellcheck disable=2119
  if ! is_git_worktree && ! is_git_bare_repo_worktree; then
    echo "Not a git repository." >&2
    return 1
  fi

  if [[ -n "$(home_to_dotfiles git --no-pager diff "$1")" ]]; then
    home_to_dotfiles git --no-pager diff "$1"
  else
    echo "No changes to show." >&2
  fi
}

function gs() {
  # shellcheck disable=2119
  if ! is_git_worktree && ! is_git_bare_repo_worktree; then
    echo "Not a git repository." >&2
    return 1
  fi

  if [[ -n "$(home_to_dotfiles git --no-pager show "$1")" ]]; then
    home_to_dotfiles git --no-pager show "$1" | tig
  else
    echo "No changes to show." >&2
  fi
}

function gdp() {
  home_to_dotfiles git --no-pager diff "$@"
}

function gdc() {
  # shellcheck disable=2119
  if ! is_git_worktree && ! is_git_bare_repo_worktree; then
    echo "Not a git repository." >&2
    return 1
  fi

  if [[ -n "$(home_to_dotfiles git --no-pager diff --cached "$1")" ]]; then
    home_to_dotfiles git --no-pager diff --cached "$1" | tig
  else
    echo "No changes to show." >&2
  fi
}

function gdcp() {
  home_to_dotfiles git --no-pager diff --cached "$@"
}

alias gcl > /dev/null && unalias gcl
function gcl() {
  git clone "$@"
}

# shellcheck disable=2120
function is_git_worktree {
  if [[ $# == 0 && "$(git rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    return 0
  elif [[ $# == 1 && "$(git -C "$1" rev-parse --is-inside-work-tree 2>/dev/null)" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

# shellcheck disable=2120
function is_git_bare_repo_worktree {
  if [[ $# == 0 && "$(git config --get core.bare)" == "true" ]]; then
    return 0
  elif [[ $# == 1 && "$(git -C "$1" config --get core.bare)" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

function is_bare_git_repository {
  if [[ $# == 0 && "$(git rev-parse --is-bare-repository 2>/dev/null)" == "true" ]]; then
    return 0
  elif [[ $# == 1 && "$(git -C "$1" rev-parse --is-bare-repository 2>/dev/null)" == "true" ]]; then
    return 0
  else
    return 1
  fi
}

function gcph() {
  function run() {
    pushd "$HOME/.dotfiles/$1" && gpr && gcp "$2" && gp origin "$1" && popd || return
  }

  local branches=("msi" "xps13" "wsl" "rackspace")
  local current_branch
  current_branch=$(git rev-parse --abbrev-ref HEAD)

  # shellcheck disable=2076
  if [[ ! " ${branches[*]} " =~ " $current_branch " ]]; then
    echo "Invalid repository." >&2
    return 1
  fi

  if [[ $# -gt 0 && "$1" == "$current_branch" ]]; then
    echo "Use a different branch than the current one."
    return 1
  fi

  # shellcheck disable=2076
  if [[ $# -gt 0 && ! "${branches[*]}" =~ " $1 " ]]; then
    echo "Invalid branch: $1." >&2
    return 1
  fi

  local head_commit
  head_commit=$(git rev-parse HEAD)

  if [[ $# -gt 0 ]]; then
    run "$1" "$head_commit"
    return
  fi

  for branch in "${branches[@]/${current_branch}}"
  do
    [[ -n "$branch" ]] && run "$branch" "$head_commit"
  done
}

function sgc() {
  local colors=("black" "red" "green" "yellow" "blue" "magenta" "cyan" "white")
  local styles=("bold" "dim" "ul" "reverse")
  local reset="\e[0m"
  local sample_text="Sample Commit"
  local code

  echo "Foreground colors:"
  for color in "${colors[@]}"; do
    case $color in
      black) code="\e[30m" ;;
      red) code="\e[31m" ;;
      green) code="\e[32m" ;;
      yellow) code="\e[33m" ;;
      blue) code="\e[34m" ;;
      magenta) code="\e[35m" ;;
      cyan) code="\e[36m" ;;
      white) code="\e[37m" ;;
    esac
    echo -e "${code}${sample_text}${reset} : ${color}"
  done

  echo -e "\nStyles:"
  for style in "${styles[@]}"; do
    case $style in
      bold) code="\e[1m" ;;
      dim) code="\e[2m" ;;
      ul) code="\e[4m" ;;
      reverse) code="\e[7m" ;;
    esac
    echo -e "${code}${sample_text}${reset} : ${style}"
  done
}

