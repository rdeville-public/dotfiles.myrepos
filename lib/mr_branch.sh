#!/usr/bin/env bash

_branch_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  vcsh run "${vcsh_repo_name}" git branch "$@"
}

_branch_git(){
  git branch "$@"
}

mr_branch(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _branch_vcsh "$@"
  else
    _branch_git "$@"
  fi
}
