#!/usr/bin/env bash

_add_vcsh_upstream(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  remote=$(vcsh run ${vcsh_repo_name} git config --get remote.origin.url)
  if [[ "${remote}" =~ rdeville.private ]]
  then
    mr_log "INFO" "Adding upstream remote for vcsh **${vcsh_repo_name}**."
    vcsh run ${vcsh_repo_name} git remote add upstream ${remote/rdeville.private/rdeville.public}
  fi
}

_add_git_upstream(){
  remote=$(git config --get remote.origin.url)
  if [[ "${remote}" =~ rdeville.private ]]
  then
    mr_log "INFO" "Adding upstream remote for **${MR_REPO/${HOME}/\~}**."
    git remote add upstream ${remote/rdeville.private/rdeville.public}
  fi
}

add_upstream(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _add_vcsh_upstream "$@"
  else
    _add_git_upstream "$@"
  fi
}

