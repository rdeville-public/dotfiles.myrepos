#!/usr/bin/env bash

_git_flow_init_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Init **git flow**."
  if [[ "$*" =~ --quiet|-q ]]
  then
    vcsh "${vcsh_repo_name}" flow init -d &> /dev/null
  else
    vcsh "${vcsh_repo_name}" flow init
  fi
}

_git_flow_init_git(){
  mr_log "INFO" "Init **git flow**."
  git flow init -d &> /dev/null
}


git_flow_init(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _git_flow_init_vcsh "$@"
  else
    _git_flow_init_git "$@"
  fi
}
