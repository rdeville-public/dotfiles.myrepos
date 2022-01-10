#!/usr/bin/env bash

include_host_repo(){
  if [[ -z "$1" ]]
  then
    include_host_repo "${HOME}/.config/mr/hosts/${HOSTNAME}"
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