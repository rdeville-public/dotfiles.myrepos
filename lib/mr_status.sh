#!/usr/bin/env bash

_status_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Status vcsh repo **${vcsh_repo_name}**."
  vcsh run ${vcsh_repo_name} git status -s "$@" || true; git --no-pager log --branches --not --remotes --simplify-by-decoration --decorate --oneline || true; git --no-pager stash list
}

_status_git(){
  repo_path="${MR_REPO/${HOME}/\~}"
  git status -s "$@" || true; git --no-pager log --branches --not --remotes --simplify-by-decoration --decorate --oneline || true; git --no-pager stash list
}

mr_status(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _status_vcsh "$@"
  else
    _status_git "$@"
  fi
}
