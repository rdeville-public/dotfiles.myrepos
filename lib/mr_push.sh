#!/usr/bin/env bash

mr_push(){
  repo_path="${MR_REPO/${HOME}/\~}"
  _log "INFO" "Push **${repo_path}**."
  git push --all "$@"
  if [[ $(git remote -v) =~ upstream ]]
  then
    git push upstream --all "$@"
  fi
}