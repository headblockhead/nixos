# vim:ft=zsh ts=2 sw=2 sts=2

# A theme by agnoster, modified by headblockhead for NixOS.

CURRENT_BG='NONE'
# DEFAULT_USER is set by home-manager.

() {
  local LC_ALL="" LC_CTYPE="en_US.UTF-8"

  # https://github.com/ryanoasis/powerline-extra-symbols#glyphs
  
  #SEGMENT_SEPARATOR=$'\ue0b0' # Regular powerline
  #SEGMENT_SEPARATOR=$'\ue0d1' # LEGO
  #SEGMENT_SEPARATOR=$'\ue0b4' # Curves
  SEGMENT_SEPARATOR=$'\ue0cc' # hexagons
  #SEGMENT_SEPARATOR=$'\ue0c0' # fire
  #SEGMENT_SEPARATOR=$'\ue0c4' # small pixel blend
  #SEGMENT_SEPARATOR=$'\ue0c6' # large pixel blend
  #SEGMENT_SEPARATOR=$'\ue0d2' # angles
  #SEGMENT_SEPARATOR=$'\ue0c8' # spikes
  #SEGMENT_SEPARATOR=$'\ue0b8' # -45deg 
  #SEGMENT_SEPARATOR=$'\ue0bc' # 45deg 
  
  SEGMENT_SEPARATOR_END=$'\ue0b0' # Regular powerline
  #SEGMENT_SEPARATOR_END=$'\ue0d1' # LEGO
  #SEGMENT_SEPARATOR_END=$'\ue0b4' # Curves
  #SEGMENT_SEPARATOR_END=$'\ue0cc' # hexagons
  #SEGMENT_SEPARATOR_END=$'\ue0c0' # fire
  #SEGMENT_SEPARATOR_END=$'\ue0c4' # small pixel blend
  #SEGMENT_SEPARATOR=_END$'\ue0c6' # large pixel blend
  #SEGMENT_SEPARATOR_END=$'\ue0d2' # angles
  #SEGMENT_SEPARATOR_END=$'\ue0c8' # spikes
  #SEGMENT_SEPARATOR_END=$'\ue0b8' # -45deg 
  #SEGMENT_SEPARATOR_END=$'\ue0bc' # 45deg 
}

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_END"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

# show the time
prompt_time() {
  prompt_segment 93 255 '%*'
}

# if there was there an error, display red X + err number
# if we are root, display a red warning triangle
prompt_status() {
  local symbols
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{grey}%}✘ %? "
  [[ $UID -eq 0 ]] && symbols+="%{%F{grey}%} "
  [[  -n "$symbols" ]] && prompt_segment 196 255 "$symbols"
}

# user@hostname, but only if we are in SSH, or have changed user and are not root
prompt_context() {
  if [[ "$USERNAME" != "$DEFAULT_USER" && "$UID" != 0 && -v DEFAULT_USER || -n "$SSH_CLIENT" ]]; then
    prompt_segment 92 255 "%(!.%{%F{bright-white}%}.)%n@%m"
  fi
}

# if there are /nix/store entries in the PATH, infer that we are in a nix-shell
prompt_nix_shell() {
  NIXSHELL=$(echo $PATH | tr ':' '\n' | grep '/nix/store' | sed 's#^/nix/store/[a-z0-9]\+-##' | sed 's#-[^-]\+$##' | xargs -n2 -d'\n')
  if [ "$NIXSHELL"  ]; then 
    prompt_segment 164 255 "nix-shell"
  fi
}

# Current DIR.
prompt_dir() {
  prompt_segment 165 255 '%~'
}

# Git: branch/detached head, dirty status
prompt_git() {
  (( $+commands[git] )) || return
  if [[ "$(git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]]; then
    return
  fi
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR=$'\ue0a0'         # 
  }
  local ref dirty mode repo_path

   if [[ "$(git rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ]]; then
    repo_path=$(git rev-parse --git-dir 2>/dev/null)
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment 209 255
    else
      prompt_segment 31 255
    fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr '✚'
    zstyle ':vcs_info:*' unstagedstr '±'
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats ' %u%c'
    vcs_info
    echo -n "${${ref:gs/%/%%}/refs\/heads\//$PL_BRANCH_CHAR }${vcs_info_msg_0_%% }${mode}"
  fi
}

build_prompt() {
  RETVAL=$?
#  prompt_time
  prompt_status
  prompt_context
  prompt_nix_shell
  prompt_dir
  prompt_git
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
