#!/usr/bin/env bash

_include_files(){
  for i_file in "$1"/*
  do
    if [[ -d "${i_file}" ]]
    then
      _include_files "${i_file}"
    elif [[ "${i_file}" =~ \.git$ ]]
    then
      cat "${i_file}"
    fi
  done
}
_compute_repo_dir(){
  if [[ "${USE_HOSTNAME}" == "false" ]] && [[ "${USE_USERNAME}" == "false" ]]
  then
    repo_dir+="/repos"
    return
  fi

  if [[ "${USE_HOSTNAME}" == "true" ]]
  then
    repo_dir+="/hosts/${HOSTNAME}"
  fi

  if [[ "${USE_USERNAME}" == "true" ]]
  then
    repo_dir+="/${USER}"
  fi
}

include_host_repo(){
  local repo_dir="$1"
  if [[ -z "${repo_dir}" ]]
  then
    repo_dir="${XDG_DATA_DIR:-${HOME}/.local/share}/mr"
  fi
  _log "INFO" "Include repos defined in ${repo_dir}"
  _compute_repo_dir
  _include_files "${repo_dir}"
}