#!/usr/bin/env bash

_check_git_repo(){
  local repo_name="${VCSH_REPO_NAME:-${PWD/${HOME}/\~}}"
  if [[ -z "${VCSH_REPO_NAME}" ]] && ! [[ -d "${PWD}/.git" ]]
  then
    mr_log "ERROR" "Repo **${repo_name}** is not a git repo, aborting."
    exit 1
  elif [[ $(git remote | wc -l) -eq 0 ]]
  then
    mr_log "ERROR" "No remote defined for **${repo_name}**, aborting."
    exit 1
  elif ! [[ "$(git remote)" =~ origin ]]
  then
    mr_log "ERROR" "No remote **origin** defined for **${repo_name}**, aborting."
    exit 1
  fi
}


_define_register_path(){
  local dest_dir_suffix=""
  local repo_type
  if [[ -n "${VCSH_REPO_NAME}" ]]
  then
    repo_type="vcsh"
  elif [[ "${PWD}" =~ ^\.config ]]
  then
    repo_type="dotfiles"
  else
    repo_type="${PWD//*git\//}"
    repo_type="$(dirname ${repo_type})"
  fi
  dest="${HOME}/.config/mr/repos/${repo_type}/${MR_REPO}.git"
  dest_host="${HOME}/.config/mr/hosts/${HOSTNAME}/${repo_type}/${MR_REPO}.git"
  dest_tmp="/tmp/${repo_type}/${MR_REPO}.git"
}


_compute_register_content(){
  local remote_origin_url="$(git config --get remote.origin.url)"
  local repo_path=""

  if [[ -n "${VCSH_REPO_NAME}" ]]
  then
    repo_path=".local/share/vcsh/repo.d/${VCSH_REPO_NAME}.git"
  else
    repo_path="${PWD#${HOME}/}"
  fi

  git_tpl="\
[${repo_path}]
checkout =
  mr_checkout ${remote_origin_url}
"

  if [[ "${remote_origin_url}" =~ rdeville.private ]]
  then
    git_tpl+="  add_upstream \"${remote_origin_url/rdeville.private/rdeville.public}\""
  fi
}


_register_repo(){
  if [[ -f "${dest}" ]]
  then
    mkdir -p "$(dirname ${dest_tmp})"
    echo "${git_tpl}" > "${dest_tmp}"
    if ! diff -q "${dest}" "${dest_tmp}"
    then
      mr_log "WARNING" "Old and new registering for **${MR_REPO}** differs."
      mr_log "WARNING" "Backup old registering for **${MR_REPO}**."
      mv "${dest}" "${dest}.bak"
    else
      mr_log "INFO" "Old and new registering for **${MR_REPO}** are the same."
    fi
  else
    mr_log "INFO" "Registering **${MR_REPO}** in **${dest/${HOME}/\~}**."
    mkdir -p "$(dirname ${dest})"
    echo "${git_tpl}" > "${dest}"
  fi
}


_symlink_repo_in_host(){
  local nb_subdir=$(echo ${dest_host/${HOME}\/.config\/mr\//} | tr -d -c "/" | wc -c)

  if ! [[ -L "${dest_host}" ]]
  then
    mr_log "INFO" "Create symlinks for **${MR_REPO}** for **${HOSTNAME}**."
    mkdir -p "$(dirname ${dest_host})"
    dest="${dest/${HOME}\/.config\/mr\//}"
    for ((i=0; i<nb_subdir; i++))
    do
      dest="../${dest//${HOME}\/.config\/mr}"
    done
    ln -s "${dest}" "${dest_host}"
  else
    mr_log "INFO" "Symlinks for **${MR_REPO}** for **${HOSTNAME}** already exists."
  fi
}


mr_register(){
  local dest_dir=""
  local dest_dir_host=""

  _check_git_repo
  _define_register_path
  _compute_register_content
  _register_repo
  _symlink_repo_in_host
}

# -----------------------------------------------------------------------------
# VIM MODELINE
# vim: fdm=indent:fdi=
# -----------------------------------------------------------------------------