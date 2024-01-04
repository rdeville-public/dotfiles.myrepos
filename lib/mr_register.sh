#!/usr/bin/env bash

_check_git_repo(){
  _is_inside_work_tree(){
    if ! git rev-parse --is-inside-work-tree &> /dev/null
    then
      _log "ERROR" "Repo **${repo_name}** is not a git repo, aborting."
      exit 1
    fi
  }

  _is_remote_defined(){
    if [[ $(git remote | wc -l) -eq 0 ]]
    then
      _log "ERROR" "No remote defined for **${repo_name}**, aborting."
      exit 1
    fi
  }

  _is_origin_defined(){
    if ! [[ "$(git remote)" =~ origin ]]
    then
      _log "ERROR" "No remote **origin** defined for **${repo_name}**, aborting."
      exit 1
    fi
  }

  local repo_name="${PWD/${HOME}/\~}"
  _is_inside_work_tree
  _is_remote_defined
  _is_origin_defined
  repo_path="$(git rev-parse --show-toplevel)"
}

_compute_path(){
  dest_file="${XDG_DATA_DIR:-${HOME}/.local/share}/mr/"

  if [[ "${USE_USERNAME}" == "false" ]] && [[ "${USE_HOSTNAME}" == "false" ]]
  then
    dest_file+="repos/"
    return
  fi

  if [[ "${USE_HOSTNAME}" == "true" ]]
  then
    dest_file+="hosts/${HOSTNAME}"
  fi

  if [[ "${USE_USERNAME}" == "true" ]]
  then
    dest_file+="/${USER}"
  fi

  dest_file+="${repo_path/${HOME}\/git/}.git"
}

_compute_register_content(){
  local remote_origin_url
  remote_origin_url="$(git config --get remote.origin.url)"
  git_tpl="\
[${repo_path/${HOME}/\$\{HOME\}}]
checkout =
  mr_checkout \"${remote_origin_url}\"

# vim: ft=dosini"
}

_register_repo(){
  local base_dir=$(dirname "${dest_file}")

  if [[ -f "${dest_file}" ]]
  then
    _log "WARNING" "Repo already registerd in **${dest_file/${HOME}/\~}**."
    _log "WARNING" "Please review this file and process accordingly (update or delete)"
    exit 1
  fi

  if ! [[ -d $(dirname "${dest_file}") ]]
  then
    _log "INFO" "Creating directory **${base_dir/${HOME}/\~}**."
    mkdir -p $(dirname "${dest_file}")
  fi

  _log "INFO" "Registering repo **${repo_path/${HOME}/\~}** to **${dest_file/${HOME}/\~}**."
  echo -e "${git_tpl}\n" > "${dest_file}"

}

mr_register(){
  local dest_file
  local git_tpl
  local repo_path

  _log "INFO" "hostname: ${USE_HOSTNAME}"
  _log "INFO" "username: ${USE_USERNAME}"

  _check_git_repo
  _compute_register_content
  _compute_path
  _register_repo
}

# vim: fdm=indent:fdi=