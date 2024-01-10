#!/usr/bin/env bash

_include_files(){
  _log "INFO" "Include repos defined in ${1}"
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
  local repo_file=""
  if [[ "${USE_HOSTNAME}" == "false" ]]
  then
    if [[ "${USE_USERNAME}" == "false" ]]
    then
      repo_dir+="/repos"
      _include_files
      return
    elif [[ "${USE_USERNAME}" == "true" ]]
    then
      repo_file="${repo_dir}/users/${USER}.git"
      if [[ -f "${repo_file}" ]]
      then
        _log "INFO" "Include repos defined in ${repo_file}"
        cat "${repo_file}"
        return
      fi
      repo_dir+="/users/${USER}"
      _include_files
      return
    fi
  fi

  if [[ "${USE_HOSTNAME}" == "true" ]]
  then
    if [[ "${USE_USERNAME}" == "false" ]]
    then
      repo_file="${repo_dir}/hosts/${HOSTNAME}.git"
      if [[ -f ${repo_file} ]]
      then
        _log "INFO" "Include repos defined in ${repo_file}"
        cat "${repo_file}"
        return
      fi
      repo_dir+="/hosts/${HOSTNAME}"
      _include_files
      return
    elif [[ "${USE_USERNAME}" == "true" ]]
    then
      repo_file="${repo_dir}/hosts/${HOSTNAME}/${USER}.git"
      if [[ -f ${repo_file} ]]
      then
        _log "INFO" "Include repos defined in ${repo_file}"
        cat "${repo_file}"
        return
      fi
      repo_dir+="/hosts/${HOSTNAME}/${USER}"
      _include_files
      return
    fi
  fi
}

include_host_repo(){
  local repo_dir="$1"
  if [[ -z "${repo_dir}" ]]
  then
    repo_dir="${XDG_DATA_DIR:-${HOME}/.local/share}/mr"
  fi
  _compute_repo_dir
}