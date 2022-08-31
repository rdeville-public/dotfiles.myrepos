#!/usr/bin/env bash

_remote_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  vcsh run "${vcsh_repo_name}" git remote "$@"
}

_remote_git(){
  git remote "$@"
}

mr_remote(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _remote_vcsh "$@"
  else
    _remote_git "$@"
  fi
}
