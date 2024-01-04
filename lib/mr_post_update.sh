#!/usr/bin/env bash

_bootstrap_dotfiles(){
  bootstrap_script="${MR_REPO}/bootstrap.sh"
  if [[ -e "${bootstrap_script}" ]] && [[ -x ${bootstrap_script} ]]
  then
    _log "INFO" "Bootstrap **${MR_REPO/${HOME}/\~}**."
    ${bootstrap_script}
  fi
}

_direnv_init(){
  if ! command -v direnv_init &> /dev/null
  then
    _log "ERROR" "Command \`direnv_init\` does not exists."
    return
  fi
  _log "INFO" "Init **direnv**."
  cd "${MR_REPO}" || return 1
  direnv_init
}

mr_post_update(){
  if [[ ${@} =~ checkout ]]
  then
    _direnv_init
  fi
  _bootstrap_dotfiles
}