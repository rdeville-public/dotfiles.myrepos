#!/usr/bin/env bash

bootstrap_dotfiles(){
  bootstrap_script="${MR_REPO}/bootstrap.sh"
  if [[ -e "${bootstrap_script}" ]] && [[ -x ${bootstrap_script} ]]
  then
    mr_log "INFO" "Bootstrap **${MR_REPO/${HOME}/\~}**."
    ${bootstrap_script}
  fi
}