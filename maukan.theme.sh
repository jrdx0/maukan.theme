#! bash oh-my-bash.module
# Maukan Bash Prompt, inspired by "Mairan"

declare -gA _MIASMA_COLORS

if tput setaf 1 &> /dev/null; then
  _MIASMA_COLORS[MIASMA_BLACK]=$(tput setaf 0)
  _MIASMA_COLORS[MIASMA_MAROON]=$(tput setaf 1)
  _MIASMA_COLORS[MIASMA_GREEN]=$(tput setaf 2)
  _MIASMA_COLORS[MIASMA_OLIVE]=$(tput setaf 3)
  _MIASMA_COLORS[MIASMA_NAVY]=$(tput setaf 4)
  _MIASMA_COLORS[MIASMA_PURPLE]=$(tput setaf 5)
  _MIASMA_COLORS[MIASMA_TEAL]=$(tput setaf 6)
  _MIASMA_COLORS[MIASMA_SILVER]=$(tput setaf 7)
  _MIASMA_COLORS[MIASMA_GREY]=$(tput setaf 8)
  _MIASMA_COLORS[MIASMA_RED]=$(tput setaf 9)
  _MIASMA_COLORS[MIASMA_LIME]=$(tput setaf 10)
  _MIASMA_COLORS[MIASMA_YELLOW]=$(tput setaf 11)
  _MIASMA_COLORS[MIASMA_BLUE]=$(tput setaf 12)
  _MIASMA_COLORS[MIASMA_FUCHSIA]=$(tput setaf 13)
  _MIASMA_COLORS[MIASMA_AQUA]=$(tput setaf 14)
  _MIASMA_COLORS[MIASMA_WHITE]=$(tput setaf 15)

  _MIASMA_COLORS[MIASMA_BOLD]=$(tput bold)
  _MIASMA_COLORS[MIASMA_RESET]=$(tput sgr0)
else
  _MIASMA_COLORS[MIASMA_BLACK]=$'\033[30m'
  _MIASMA_COLORS[MIASMA_MAROON]=$'\033[31m'
  _MIASMA_COLORS[MIASMA_GREEN]=$'\033[32m'
  _MIASMA_COLORS[MIASMA_OLIVE]=$'\033[33m'
  _MIASMA_COLORS[MIASMA_NAVY]=$'\033[34m'
  _MIASMA_COLORS[MIASMA_PURPLE]=$'\033[35m'
  _MIASMA_COLORS[MIASMA_TEAL]=$'\033[36m'
  _MIASMA_COLORS[MIASMA_SILVER]=$'\033[37m'
  _MIASMA_COLORS[MIASMA_GREY]=$'\033[90m'
  _MIASMA_COLORS[MIASMA_RED]=$'\033[91m'
  _MIASMA_COLORS[MIASMA_LIME]=$'\033[92m'
  _MIASMA_COLORS[MIASMA_YELLOW]=$'\033[93m'
  _MIASMA_COLORS[MIASMA_BLUE]=$'\033[94m'
  _MIASMA_COLORS[MIASMA_FUCHSIA]=$'\033[95m'
  _MIASMA_COLORS[MIASMA_AQUA]=$'\033[96m'
  _MIASMA_COLORS[MIASMA_WHITE]=$'\033[97m'

  _MIASMA_COLORS[MIASMA_BOLD]=$'\033[1m'
  _MIASMA_COLORS[MIASMA_RESET]=$'\033[m'
fi

for KEY in "${!_MIASMA_COLORS[@]}"; do
  declare -g "_${KEY}=${_MIASMA_COLORS[$KEY]}"
  declare -g "${KEY}=\[${_MIASMA_COLORS[$KEY]}\]"
done

BRACKET_COLOR=$MIASMA_RED

SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${MIASMA_BOLD}${MIASMA_FUCHSIA}${MIASMA_RESET}"
SCM_THEME_PROMPT_CLEAN=" ${MIASMA_BOLD}${MIASMA_NAVY}${MIASMA_RESET}"
SCM_GIT_CHAR=""

export MYSQL_PS1="(\u@\h) [\d]> "

case $TERM in
xterm*)
  TITLEBAR="\[\033]0;\w\007\]"
  ;;
*)
  TITLEBAR=""
  ;;
esac

PS3=">> "

function get_project_dir {
  local CHAR=$(scm_char)

  if [[ $CHAR == "$SCM_NONE_CHAR" ]]; then
    echo $PWD
  else
    echo $(git rev-parse --show-toplevel)
  fi
}

function modern_scm_prompt {
  local R_RED="\001${_MIASMA_RED}\002"
  local CHAR=$(scm_char)

  if [[ $CHAR == "$SCM_NONE_CHAR" ]]; then
    if [[ -n $HOME && $HOME == $(pwd) ]]; then
      _omb_util_print "${R_RED}"
      return
    fi

    _omb_util_print "${R_RED}\w"
    return
  fi

  local R_YELLOW="\001${_MIASMA_YELLOW}\002"
  local R_TEAL="\001${_MIASMA_TEAL}\002"

  local REPO_NAME=$(basename $(git rev-parse --show-toplevel))
  local PREFIX=$(git rev-parse --show-prefix | awk -F'/' '{
    n=NF-1
    if (n<=2) print $0
    else print ".../" $(NF-2) "/" $(NF-1)
  }')

  if git rev-parse HEAD &> /dev/null 2>&1; then
    local BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    local BRANCH_LABEL=" ${R_TEAL}($(scm_prompt_info)${R_TEAL})"
  else
    local BRANCH_LABEL="$(scm_prompt_info)"
  fi

  if [[ -n $PREFIX ]]; then
    _omb_util_print "${R_YELLOW}${CHAR} ${REPO_NAME}/${PREFIX%/}${BRANCH_LABEL}"
  else
    _omb_util_print "${R_YELLOW}${CHAR} ${REPO_NAME}${BRANCH_LABEL}"
  fi
}

function bun_prompt {
  [[ -z $BUN_INSTALL ]] && return
  [[ ! -f "$(get_project_dir)/bun.lock" ]] && return

  local R_SILVER="\001${_MIASMA_SILVER}\002"
  _omb_util_print "${O_BKT}${R_SILVER} $(bun -v)${C_BKT}"
}


function node_prompt {
  local DIR=$(get_project_dir)

  [[ -f "${DIR}/bun.lock" ]] && return
  [[ ! -d "${DIR}/node_modules" ]] && return

  local NODE_SYMBOL=""
  local NODE_VERSION=$(node -v)

  local R_BLUE="\001${_MIASMA_BLUE}\002"
  _omb_util_print "${O_BKT}${R_BLUE} ${NODE_VERSION:1}${C_BKT}"
}

function _omb_theme_PROMPT_COMMAND {
  local MY_PS="${MIASMA_BOLD}${MIASMA_GREEN}󱚡 \u@\h${MIASMA_RESET}"

  local O_BKT="${BRACKET_COLOR}[${MIASMA_RESET}"
  local C_BKT="${BRACKET_COLOR}]${MIASMA_RESET}"

  local PS="${O_BKT}${MY_PS}${C_BKT}"
  local SCM_PROMPT="${O_BKT}$(modern_scm_prompt)${C_BKT}"

  case $(id -u) in
    *) PS1="${TITLEBAR}${MIASMA_WHITE}─▪${MIASMA_RESET}${PS}${SCM_PROMPT}${MIASMA_RESET}$(bun_prompt)$(node_prompt) "
     ;;
  esac
}

PS2="└─▪ "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
