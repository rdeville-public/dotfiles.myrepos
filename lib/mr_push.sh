#!/usr/bin/env bash

_push_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Pull vcsh repo **${vcsh_repo_name}**."
  vcsh run ${vcsh_repo_name} git push --all "$@"
  if [[ $(vcsh run ${vcsh_repo_name} git remote -v) =~ upstream ]]
  then
    vcsh run ${vcsh_repo_name} git push upstream --all "$@"
  fi
}

_push_git(){
  repo_path="${MR_REPO/${HOME}/\~}"
  mr_log "INFO" "Pull **${repo_path}**."
  git push --quiet --all "$@"
  if [[ $(git remote -v) =~ upstream ]]
  then
    git push upstream --all "$@"
  fi
}

mr_push(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _push_vcsh "$@"
  else
    _push_git "$@"
  fi
}

