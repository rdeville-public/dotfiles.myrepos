#!/usr/bin/env bash

_direnv_init_git()
{
  if [[ -x "${HOME}/.local/bin/direnv_init" ]]
  then
    mr_log "INFO" "Init **direnv**."
    cd "${MR_REPO}" || return 1
    "${HOME}"/.local/bin/direnv_init
  fi
}

# shellcheck disable=SC2120
direnv_init(){
  if [[ "${MR_REPO}" =~ \.git$ ]]
  then
    mr_log "WARNING" "\`direnv_init\` is not support for **vcsh** repo, nothing to do."
  else
    _direnv_init_git "$@"
  fi
}
