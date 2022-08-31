#!/usr/bin/env bash

_checkout_vcsh(){
  vcsh_repo_name=$(basename "${MR_REPO#*:}" .git)
  mr_log "INFO" "Clone vcsh repo **${vcsh_repo_name}**."
  VCSH_BASE="${HOME}/.config/${vcsh_repo_name}" vcsh clone "$@" "${vcsh_repo_name}"
  mr_log "INFO" "Pull all remote branches."
  vcsh "${vcsh_repo_name}" pull --all "$@";
}

_checkout_git(){
  repo_path=${MR_REPO/${HOME}/\~}
  mr_log "INFO" "Clone **${repo_path}**."
  git clone -q --recurse-submodules "$@" "${MR_REPO}"
  cd "${MR_REPO}" || return 1
  mr_log "INFO" "Pull all remote branches"
  if [[ $* =~ --quiet|-q ]]
  then
    git pull --all --quiet;
  else
    git pull --all;
  fi
}

mr_checkout(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    _checkout_vcsh "$@"
  else
    _checkout_git "$@"
  fi
}