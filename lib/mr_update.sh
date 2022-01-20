#!/usr/bin/env bash

_update_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Pull vcsh repo **${vcsh_repo_name}**."
  vcsh run ${vcsh_repo_name} git pull $@
}

_update_git(){
  repo_path="${MR_REPO/${HOME}/\~}"
  mr_log "INFO" "Pull **${repo_path}**."
  git pull "$@"
}

mr_update(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _update_vcsh "$@"
  else
    _update_git "$@"
  fi
}