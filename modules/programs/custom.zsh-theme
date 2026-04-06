# Original theme code by agnoster, heavily modified by headblockhead.

prompt_git() {
  (( $+commands[git] )) || return

  if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="-> $(git rev-parse --short HEAD 2> /dev/null)"

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode="<B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=">M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=">R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '+'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats '%u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'
    vcs_info

    dirty=$(parse_git_dirty)
    if [[ -n $dirty ]]; then
      color="%{\e[1;33m%}" # set FG color to yellow
    else
      color="%{\e[1;36m%}" # set FG color to cyan
    fi
    echo -n "[${color}${${ref:gs/%/%%}/refs\/heads\//}${vcs_info_msg_0_%%}${mode}%{\e[0m%}]"
  fi
}

build_prompt() {
  RETURN_VALUE=$?

  # Display return value if non-zero.
  [[ $RETURN_VALUE -ne 0 ]] && echo -n "(%{\e[1;31m%}X%?%{\e[0m%})"

  # user@hostname, but only if we are in SSH, or have changed user and are not root.
  if [[ "$USERNAME" != "$DEFAULT_USER" && "$UID" != 0 && -v DEFAULT_USER || -n "$SSH_CLIENT" ]]; then
    echo -n "%{\e[1;32m%}%n@%m%{\e[0m:%}"
  fi

  # Display current dir.
  echo -n '%{\e[1;34m%}%~%{\e[0m%}'

  # if there are /nix/store entries in the PATH, infer that we are in a nix-shell.
  NIXSHELL=$(echo $PATH | tr ':' '\n' | grep '/nix/store' | sed 's#^/nix/store/[a-z0-9]\+-##' | sed 's#-[^-]\+$##' | xargs -n2 -d'\n')
  if [ "$NIXSHELL"  ]; then
    echo -n "[%{\e[1;35m%}nix-shell%{\e[0m%}]"
  fi

  prompt_git

  # Display '#' if root, and '$' otherwise.
  if [[ $UID -eq 0 ]]; then
   echo -n "# "
 else
   echo -n "$ "
  fi
}

PROMPT='%{%f%b%k%}$(build_prompt)'
