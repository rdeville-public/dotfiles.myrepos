#!/usr/bin/env bash

_checkout_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Clone vcsh repo **${vcsh_repo_name}**."
  VCSH_BASE="${HOME}/.config/${vcsh_repo_name}" vcsh clone "$1" "${vcsh_repo_name}"
  mr_log "INFO" "Pull all remote branches."
  vcsh "${vcsh_repo_name}" pull --quiet --all;
  mr_log "INFO" "Init git flow."
  vcsh "${vcsh_repo_name}" flow init -d &> /dev/null
  direnv_init
}

_checkout_git(){
  repo_path=${MR_REPO/${HOME}/\~}
  mr_log "INFO" "Clone **${repo_path}**."
  git clone "$1" "${MR_REPO}" --quiet
  cd ${MR_REPO}
  mr_log "INFO" "Pull all remote branches"
  git pull --quiet --all;
  add_upstream
  mr_log "INFO" "Init git flow."
  git flow init -d &> /dev/null
  direnv_init
}

mr_checkout(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _checkout_vcsh "$1" "$2"
  else
    _checkout_git "$1"
  fi
}