#!/usr/bin/env bash

include_host_repo(){
  if [[ -z "$1" ]]
  then
    include_dir="${XDG_DATA_DIR:-${HOME}/.local/share}/mr"
    if ! [[ -e "/.dockerenv" ]]
    then
      if [[ "${USE_HOSTNAME}" == "false" ]] && [[ "${USE_USERNAME}" == "false" ]]
      then
        include_dir+="/repos"
      else
        if [[ "${USE_HOSTNAME}" == "true" ]]
        then
          include_dir+="/hosts/${HOSTNAME}"
        fi
        if [[ "${USE_USERNAME}" == "true" ]]
        then
          include_dir+="/${USER}"
        fi
      fi
      for i_file in "${include_dir}"/*
      do
        if [[ $(basename "${i_file}") != "${USER}" ]]
        then
          include_host_repo "${include_dir}"
        fi
      done
    else
      include_dir+="/hosts/docker"
      include_host_repo "${include_dir}"
    fi
  else
    for i_file in "$1"/*
    do
      if [[ -d "${i_file}" ]]
      then
        include_host_repo ${i_file}
      elif [[ "${i_file}" =~ \.(git|vcsh)$ ]]
      then
        cat ${i_file}
      fi
    done
  fi
}