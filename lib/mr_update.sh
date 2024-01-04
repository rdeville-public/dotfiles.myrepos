#!/usr/bin/env bash

mr_update(){
  repo_path="${MR_REPO/${HOME}/~}"
  _log "INFO" "Pull **${repo_path}**."
  git pull "$@"
}